import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ContentSourcesView extends StatelessWidget {
  const ContentSourcesView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sources and licences')),
    body: ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Learning content you can trace',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'We show where reusable learning data came from, how it may be shared and what its limits are.',
          ),
          const SizedBox(height: 15),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hanabira Japanese grammar',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                  ),
                  SizedBox(height: 6),
                  Text('828 community-proofread grammar points, N5 to N1.'),
                  SizedBox(height: 6),
                  Text(
                    'Source: hanabira.org and tristcoil/hanabira.org-japanese-content',
                  ),
                  Text('Licence: Creative Commons BY-SA 3.0'),
                  Text(
                    'Imported source revision: fb2d03f14e8000ef3c77612c7770e425c012c904',
                  ),
                  SizedBox(height: 10),
                  Text(
                    'LinguaTomo adds navigation, stable identifiers, bookmarks and FSRS scheduling. We exclude the repository’s commercial-textbook-derived sentence collections.',
                  ),
                ],
              ),
            ),
          ),
          const Card(
            color: AppColors.bambooMist,
            child: Padding(
              padding: EdgeInsets.all(17),
              child: Text(
                'JLPT level labels are study references. Since 2010, the JLPT does not publish official vocabulary, kanji or grammar lists. CEFR and ILR mappings are broad guidance, not score conversions or certificates.',
              ),
            ),
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(17),
              child: Text(
                'Quality promise: sourced content is reviewed before it becomes assessment material. A source badge means traceable provenance, not official endorsement by the source organisation.',
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
