import 'package:algolia/algolia.dart';

class AlgoliaApplication {
  static final Algolia algolia = Algolia.init(
    applicationId: 'LE5AUWRJUG', //ApplicationID
    apiKey:
        '8eb8ca873a4533b567467f978a09bc02', //search-only api key in flutter code
  );
}
