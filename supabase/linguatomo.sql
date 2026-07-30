-- LinguaTomo canonical cloud schema.
-- Schema version: 1.17.9 (build 39), July 2026.
-- Reapply this single file after every release. It is safe for both a fresh
-- project and an existing LinguaTomo project. Local Hive data remains the
-- offline source of truth. Never place service-role secrets in this file.
create extension if not exists pgcrypto;

do $$ begin
  create type public.account_mode as enum ('adult', 'family_child');
exception when duplicate_object then null;
end $$;
do $$ begin
  create type public.friendship_status as enum ('pending', 'accepted', 'blocked');
exception when duplicate_object then null;
end $$;
do $$ begin
  create type public.moderation_status as enum ('pending', 'published', 'hidden', 'removed');
exception when duplicate_object then null;
end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text check (char_length(display_name) between 1 and 40),
  leaderboard_opt_in boolean not null default false,
  achievement_count integer not null default 0 check (achievement_count >= 0),
  xp integer not null default 0 check (xp >= 0),
  account_mode public.account_mode not null default 'adult',
  guardian_id uuid references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles
  add column if not exists leaderboard_opt_in boolean not null default false,
  add column if not exists achievement_count integer not null default 0,
  add column if not exists xp integer not null default 0;

do $$ begin
  alter table public.profiles add constraint child_requires_guardian
    check (account_mode = 'adult' or guardian_id is not null);
exception when duplicate_object then null;
end $$;
do $$ begin
  alter table public.profiles add constraint leaderboard_is_adult_only
    check (not leaderboard_opt_in or account_mode = 'adult');
exception when duplicate_object then null;
end $$;
do $$ begin
  alter table public.profiles add constraint achievement_count_non_negative
    check (achievement_count >= 0);
exception when duplicate_object then null;
end $$;
do $$ begin
  alter table public.profiles add constraint xp_non_negative
    check (xp >= 0);
exception when duplicate_object then null;
end $$;

create unique index if not exists profiles_public_name_unique
on public.profiles (lower(display_name))
where leaderboard_opt_in;

create table if not exists public.learner_progress (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  snapshot jsonb not null default '{}'::jsonb,
  client_updated_at timestamptz not null,
  server_updated_at timestamptz not null default now(),
  constraint snapshot_is_object check (jsonb_typeof(snapshot) = 'object')
);

-- The publishable key is public by design, so any authenticated account can
-- write its own snapshot. A learner's complete progress is a few tens of
-- kilobytes; 256 KB leaves generous headroom while stopping one account from
-- filling the project's storage.
do $$ begin
  alter table public.learner_progress add constraint snapshot_within_size_limit
    check (pg_column_size(snapshot) <= 262144);
exception when duplicate_object then null;
end $$;

create table if not exists public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id) on delete cascade,
  addressee_id uuid not null references public.profiles(id) on delete cascade,
  status public.friendship_status not null default 'pending',
  created_at timestamptz not null default now(),
  unique (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

create table if not exists public.friend_challenges (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.profiles(id) on delete cascade,
  opponent_id uuid not null references public.profiles(id) on delete cascade,
  mission_id text not null,
  creator_score smallint check (creator_score between 0 and 100),
  opponent_score smallint check (opponent_score between 0 and 100),
  expires_at timestamptz not null default (now() + interval '7 days'),
  created_at timestamptz not null default now(),
  check (creator_id <> opponent_id)
);

create table if not exists public.community_posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 1000),
  image_path text,
  status public.moderation_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.content_reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts(id) on delete cascade,
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reason text not null check (char_length(reason) between 3 and 300),
  created_at timestamptz not null default now(),
  unique (post_id, reporter_id)
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, account_mode)
  values (
    new.id,
    coalesce(left(new.raw_user_meta_data ->> 'display_name', 40), 'Learner'),
    'adult'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Leaderboard figures arrive from the client, which a determined learner can
-- edit. The board is meant to be gentle, not competitive enough to be worth
-- policing hard, so this trigger only rules out the dishonest extremes:
-- scores never fall, they cannot climb faster than sustained real study, and
-- the safeguarding fields are not client-writable at all.
create or replace function public.guard_profile_update()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
declare
  elapsed_hours numeric;
  allowance integer;
begin
  -- Safeguarding fields change only through an administrative path.
  new.account_mode := old.account_mode;
  new.guardian_id := old.guardian_id;
  new.id := old.id;
  new.created_at := old.created_at;
  new.updated_at := now();

  if new.xp < old.xp then
    new.xp := old.xp;
  end if;
  if new.achievement_count < old.achievement_count then
    new.achievement_count := old.achievement_count;
  end if;

  -- The first non-zero write imports however much was earned offline before
  -- the learner made an account. Everything after that is rate-limited.
  if old.xp > 0 and new.xp > old.xp then
    elapsed_hours := greatest(
      extract(epoch from (now() - old.updated_at)) / 3600.0,
      0.02
    );
    allowance := ceil(elapsed_hours * 5000)::integer;
    if new.xp - old.xp > allowance then
      new.xp := old.xp + allowance;
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists on_profile_update on public.profiles;
create trigger on_profile_update
before update on public.profiles
for each row execute procedure public.guard_profile_update();

create or replace function public.is_adult_profile(profile_id uuid)
returns boolean
language sql
stable
security definer set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = profile_id and account_mode = 'adult'
  );
$$;

alter table public.profiles enable row level security;
alter table public.learner_progress enable row level security;
alter table public.friendships enable row level security;
alter table public.friend_challenges enable row level security;
alter table public.community_posts enable row level security;
alter table public.content_reports enable row level security;

drop policy if exists "read own or guarded profile" on public.profiles;
create policy "read own or guarded profile"
on public.profiles for select to authenticated
using (
  id = auth.uid()
  or guardian_id = auth.uid()
  or (leaderboard_opt_in and account_mode = 'adult')
);

drop policy if exists "adults update own profile" on public.profiles;
create policy "adults update own profile"
on public.profiles for update to authenticated
using (id = auth.uid() and account_mode = 'adult')
with check (id = auth.uid() and account_mode = 'adult');

drop policy if exists "own progress only" on public.learner_progress;
create policy "own progress only"
on public.learner_progress for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "friendship parties can read" on public.friendships;
create policy "friendship parties can read"
on public.friendships for select to authenticated
using (requester_id = auth.uid() or addressee_id = auth.uid());

drop policy if exists "adults can request friendships" on public.friendships;
create policy "adults can request friendships"
on public.friendships for insert to authenticated
with check (requester_id = auth.uid() and public.is_adult_profile(auth.uid()));

drop policy if exists "friendship parties can update" on public.friendships;
create policy "friendship parties can update"
on public.friendships for update to authenticated
using (requester_id = auth.uid() or addressee_id = auth.uid())
with check (requester_id = auth.uid() or addressee_id = auth.uid());

drop policy if exists "challenge parties can read" on public.friend_challenges;
create policy "challenge parties can read"
on public.friend_challenges for select to authenticated
using (creator_id = auth.uid() or opponent_id = auth.uid());

drop policy if exists "adults can create challenges" on public.friend_challenges;
create policy "adults can create challenges"
on public.friend_challenges for insert to authenticated
with check (creator_id = auth.uid() and public.is_adult_profile(auth.uid()));

drop policy if exists "challenge parties can update scores" on public.friend_challenges;
create policy "challenge parties can update scores"
on public.friend_challenges for update to authenticated
using (creator_id = auth.uid() or opponent_id = auth.uid())
with check (creator_id = auth.uid() or opponent_id = auth.uid());

drop policy if exists "authenticated users read published posts" on public.community_posts;
create policy "authenticated users read published posts"
on public.community_posts for select to authenticated
using (status = 'published' or author_id = auth.uid());

drop policy if exists "adults submit posts for moderation" on public.community_posts;
create policy "adults submit posts for moderation"
on public.community_posts for insert to authenticated
with check (
  author_id = auth.uid()
  and public.is_adult_profile(auth.uid())
  and status = 'pending'
);

drop policy if exists "authors edit only pending posts" on public.community_posts;
create policy "authors edit only pending posts"
on public.community_posts for update to authenticated
using (author_id = auth.uid() and status = 'pending')
with check (author_id = auth.uid() and status = 'pending');

drop policy if exists "authenticated users report content" on public.content_reports;
create policy "authenticated users report content"
on public.content_reports for insert to authenticated
with check (reporter_id = auth.uid());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'handwriting-private',
  'handwriting-private',
  false,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

drop policy if exists "users manage own handwriting objects" on storage.objects;
create policy "users manage own handwriting objects"
on storage.objects for all to authenticated
using (
  bucket_id = 'handwriting-private'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'handwriting-private'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create index if not exists learner_progress_updated_idx on public.learner_progress (server_updated_at desc);
create index if not exists community_posts_status_created_idx on public.community_posts (status, created_at desc);
create index if not exists challenges_opponent_idx on public.friend_challenges (opponent_id, expires_at);
