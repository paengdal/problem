// Collection명
const COL_USERS = 'Users';
const COL_ITEMS = 'Items';
const COL_COMMENTS = 'Comments';
const COL_COMMENTREPLY = 'CommentReply';
const COL_BOOKS = 'Books';

// Users Collection 관련
const KEY_USERKEY = 'user_key';
const KEY_PROFILEIMG = 'profile_img';
const KEY_EMAIL = 'email';
const KEY_TOKEN = 'token';
const KEY_LIKEDITEMS = 'liked_items';
const KEY_SOLVEDITEMS = 'solved_items';
const KEY_NUMOFFOLLOWERS = 'num_of_followers';
const KEY_FOLLOWINGS = 'followings';
const KEY_MYITEMS = 'my_items';
const KEY_USERNAME = 'username';
const KEY_CREATEDATE = 'create_date';
const KEY_MYBOOKS = 'my_books';
const KEY_LIKEDBOOKS = 'liked_books';
const KEY_SOLVEDBOOKSANDSCORE = 'solved_books_and_score';

// Items Collection 관련
const KEY_ITEMKEY = 'item_key';
const KEY_ITEMIMG = 'item_img';
const KEY_ITEMURI = 'item_uri';
const KEY_LASTCOMMENT = 'last_comment';
const KEY_LASTCOMMENTOR = 'last_commentor';
const KEY_LASTCOMMENTTIME = 'last_comment_time';
const KEY_NUMOFLIKES = 'num_of_likes';
const KEY_SOLVEDUSERS = 'solved_users';
const KEY_NUMOFCOMMENTS = 'num_of_comments';
const KEY_ITEMTIME = 'item_time';
const KEY_IMAGEDOWNLOADURLS = 'image_download_urls';
const KEY_ANSWER = 'answer';
const KEY_HINT = 'hint';
const KEY_OPTIONS = 'options';
const KEY_QUESTION = 'question';
const KEY_CATEGORY = 'category';
const KEY_DIFFICULTY = 'difficulty';
const DIFFICULTY_EASY = 'easy';
const DIFFICULTY_NORMAL = 'normal';
const DIFFICULTY_HARD = 'hard';

// Comments Collection 관련
const KEY_COMMENTKEY = 'comment_key';
const KEY_COMMENT = 'comment';
const KEY_COMMENTTIME = 'comment_time';
const KEY_NUMOFCOMMENTREPLIES = 'num_of_comment_replies';

// CommentReply 관련
const KEY_COMMENTREPLYKEY = 'commentReply_key';
const KEY_COMMENTREPLY = 'commentReply';
const KEY_COMMENTREPLYTIME = 'commentReply_time';
const KEY_COMMENTREOFRENAME = 'comment_re_of_re_name';

// Books Collection 관련
const KEY_BOOKKEY = 'book_key';
const KEY_BOOKTITLE = 'book_title';
// const KEY_BOOKCATEGORY = 'book_category';
const KEY_BOOKITEMS = 'book_items';
const KEY_SOLVEDUSERSANDSCORE = 'solved_users_and_score';
const KEY_BOOKTIME = 'book_time';
const KEY_BOOKUSERS = 'book_users'; // Book을 볼 수 있는 user
const KEY_BOOKDESC = 'book_desc'; // Book 설명
const KEY_BOOKTAGS = 'book_tags';
const KEY_NUMOFLIKESBOOK = 'num_of_likes_book';
const KEY_SCOREOFBOOK = 'score_of_book';
const KEY_SOLVINGPAGE = 'solving_page'; // 문제집에서 풀고 있던 문제 페이지 기록
const KEY_SOLVINGSTATUS = 'solving_status';
const KEY_MODEOFBOOK = 'mode_of_book'; // normal, test, timeAttack,
const MODE_NORMAL = 'normal';
const MODE_TEST = 'test';
const MODE_TIMEATTACK = 'timeAttack';
