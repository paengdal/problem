import 'package:algolia/algolia.dart';
import 'package:quiz_first/model/book_model.dart';

const Algolia algolia = Algolia.init(
  applicationId: 'YW8TYSR319',
  apiKey: 'abe1a912453ca881a654d91bac04c144',
);

class AlgoliaService {
  static final AlgoliaService _algoliaService = AlgoliaService._internal();
  factory AlgoliaService() => _algoliaService;
  AlgoliaService._internal();

  Future<List<BookModel>> queryBooks(String queryStr) async {
    /// Perform Query
    ///
    AlgoliaQuery query = algolia.instance.index('Books').query(queryStr);

    // Perform multiple facetFilters
    // query = query.facetFilter('status:published');
    // query = query.facetFilter('isDelete:false');

    // Get Result/Objects
    AlgoliaQuerySnapshot algoliaQuerySnapshot = await query.getObjects();
    List<AlgoliaObjectSnapshot> hits = algoliaQuerySnapshot.hits;
    List<BookModel> books = [];
    hits.forEach((element) {
      BookModel book =
          BookModel.fromAlgoliaObject(element.data, element.objectID);
      books.add(book);
    });

    return books;
  }
}
