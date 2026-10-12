import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// Wikilinks from the text to their targets over the real parser — the one
/// place the bracket syntax, the domain's reading and the resolver meet.
void main() {
  const MarkdownBlockReaderImpl reader = MarkdownBlockReaderImpl(
    markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
  );
  const WikilinkResolverService resolver = WikilinkResolverService();

  SpaceEntryValueObject file(String path) => SpaceEntryValueObject(
    path: SpaceRelativePathValueObject(path),
    type: SpaceEntryTypeEnum.file,
  );

  final List<SpaceEntryValueObject> space = <SpaceEntryValueObject>[
    file('technical/architecture.md'),
    file('product/export/doc.md'),
    file('product/wikilinks/doc.md'),
  ];

  /// The links of [markdown], or the test failing.
  Future<List<WikilinkValueObject>> linksOf(String markdown) async {
    final Result<ParsedDocumentValueObject, DocumentFailure> result =
        await reader.read(
          DocumentEntity(
            path: SpaceRelativePathValueObject('guides/writing.md'),
            content: markdown,
          ),
        );
    return switch (result) {
      Success<ParsedDocumentValueObject, DocumentFailure>(
        value: final ParsedDocumentValueObject document,
      ) =>
        document.wikilinks,
      Failure<ParsedDocumentValueObject, DocumentFailure>(
        failure: final DocumentFailure failure,
      ) =>
        fail('parsing failed: ${failure.diagnostics}'),
    };
  }

  test('each of the three answers comes out of real prose', () async {
    final List<WikilinkValueObject> links = await linksOf(
      '# Guide\n\n'
      'Read [[architecture#graph|the graph]], then [[doc]].\n\n'
      '- Not yet: [[roadmap]]\n\n'
      '```\n[[architecture]] in a fence is text\n```\n',
    );

    expect(links, const <WikilinkValueObject>[
      WikilinkValueObject(
        target: 'architecture',
        anchor: 'graph',
        label: 'the graph',
      ),
      WikilinkValueObject(target: 'doc'),
      WikilinkValueObject(target: 'roadmap'),
    ]);
    expect(
      <WikilinkTargetValueObject>[
        for (final WikilinkValueObject link in links)
          resolver.resolve(link, space),
      ],
      <WikilinkTargetValueObject>[
        WikilinkTargetValueObject.resolved(
          SpaceRelativePathValueObject('technical/architecture.md'),
        ),
        WikilinkTargetValueObject.ambiguous(<SpaceRelativePathValueObject>[
          SpaceRelativePathValueObject('product/export/doc.md'),
          SpaceRelativePathValueObject('product/wikilinks/doc.md'),
        ]),
        const WikilinkTargetValueObject.missing(),
      ],
    );
  });

  test('an anchor alone is the document it is written in', () async {
    final SpaceRelativePathValueObject here = SpaceRelativePathValueObject(
      'guides/writing.md',
    );

    final List<WikilinkValueObject> links = await linksOf(
      '# Guide\n\nJump to [[#Troubleshooting]].\n\n## Troubleshooting\n',
    );

    expect(links, const <WikilinkValueObject>[
      WikilinkValueObject(target: '', anchor: 'Troubleshooting'),
    ]);
    expect(
      resolver.resolve(links.single, space, origin: here),
      WikilinkTargetValueObject.resolved(here),
    );
  });
}
