-- LinguaTomo canonical cloud schema.
-- Schema version: 1.2.0 (build 3), 22 July 2026.
-- Apply this single file to a fresh Supabase project. Local Hive data remains
-- the offline source of truth. Never place service-role secrets in this file.
create extension if not exists pgcrypto;

create type public.account_mode as enum ('adult', 'family_child');
create type public.friendship_status as enum ('pending', 'accepted', 'blocked');
create type public.moderation_status as enum ('pending', 'published', 'hidden', 'removed');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text check (char_length(display_name) between 1 and 40),
  account_mode public.account_mode not null default 'adult',
  guardian_id uuid references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint child_requires_guardian check (
    account_mode = 'adult' or guardian_id is not null
  )
);

create table public.learner_progress (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  snapshot jsonb not null default '{}'::jsonb,
  client_updated_at timestamptz not null,
  server_updated_at timestamptz not null default now(),
  constraint snapshot_is_object check (jsonb_typeof(snapshot) = 'object')
);

create table public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id) on delete cascade,
  addressee_id uuid not null references public.profiles(id) on delete cascade,
  status public.friendship_status not null default 'pending',
  created_at timestamptz not null default now(),
  unique (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

create table public.friend_challenges (
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

create table public.community_posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 1000),
  image_path text,
  status public.moderation_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.content_reports (
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

create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

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

create policy "read own or guarded profile"
on public.profiles for select to authenticated
using (id = auth.uid() or guardian_id = auth.uid());

create policy "own progress only"
on public.learner_progress for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "friendship parties can read"
on public.friendships for select to authenticated
using (requester_id = auth.uid() or addressee_id = auth.uid());

create policy "adults can request friendships"
on public.friendships for insert to authenticated
with check (requester_id = auth.uid() and public.is_adult_profile(auth.uid()));

create policy "friendship parties can update"
on public.friendships for update to authenticated
using (requester_id = auth.uid() or addressee_id = auth.uid())
with check (requester_id = auth.uid() or addressee_id = auth.uid());

create policy "challenge parties can read"
on public.friend_challenges for select to authenticated
using (creator_id = auth.uid() or opponent_id = auth.uid());

create policy "adults can create challenges"
on public.friend_challenges for insert to authenticated
with check (creator_id = auth.uid() and public.is_adult_profile(auth.uid()));

create policy "challenge parties can update scores"
on public.friend_challenges for update to authenticated
using (creator_id = auth.uid() or opponent_id = auth.uid())
with check (creator_id = auth.uid() or opponent_id = auth.uid());

create policy "authenticated users read published posts"
on public.community_posts for select to authenticated
using (status = 'published' or author_id = auth.uid());

create policy "adults submit posts for moderation"
on public.community_posts for insert to authenticated
with check (
  author_id = auth.uid()
  and public.is_adult_profile(auth.uid())
  and status = 'pending'
);

create policy "authors edit only pending posts"
on public.community_posts for update to authenticated
using (author_id = auth.uid() and status = 'pending')
with check (author_id = auth.uid() and status = 'pending');

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

create index learner_progress_updated_idx on public.learner_progress (server_updated_at desc);
create index community_posts_status_created_idx on public.community_posts (status, created_at desc);
create index challenges_opponent_idx on public.friend_challenges (opponent_id, expires_at);
