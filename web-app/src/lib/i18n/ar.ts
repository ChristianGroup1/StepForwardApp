export const ar = {
  // Common
  appName: "خطوة للأمام",
  appTagline: "مجتمع خدام الكنيسة",
  loading: "جارٍ التحميل...",
  search: "بحث",
  all: "الكل",
  viewAll: "عرض الكل",
  save: "حفظ التغييرات",
  cancel: "إلغاء",
  back: "رجوع",

  // Navigation tabs
  tabHome: "الرئيسية",
  tabGames: "الألعاب",
  tabBrothers: "الخدام",
  tabMore: "المزيد",

  // Home
  homeGreeting: "مرحباً",
  homeSubtitle: "اكتشف الألعاب والخدام والكتب",
  sectionGames: "الألعاب",
  sectionBrothers: "الخدام",
  sectionBooks: "الكتب",

  // Games
  gamesTitle: "الألعاب",
  gamesSearchPlaceholder: "ابحث عن لعبة...",
  gamesEmpty: "لا توجد ألعاب",
  gamesEmptySubtitle: "جرب البحث بكلمات مختلفة",
  addToFavorites: "أضف للمفضلة",
  removeFromFavorites: "إزالة من المفضلة",
  gameNotFound: "اللعبة غير موجودة",
  gameExplanation: "شرح اللعبة",
  gameTools: "الأدوات المطلوبة",
  gameLaws: "القوانين",
  gameTarget: "الهدف من اللعبة",
  gameVideo: "فيديو اللعبة",
  gameAgeTags: "السن المناسب",
  translateToArabic: "ترجمة للعربية",
  translateToEnglish: "Translate to English",
  translating: "جارٍ الترجمة...",
  translationError: "حدث خطأ في الترجمة",
  showOriginal: "عرض النص الأصلي",

  // Brothers
  brothersTitle: "الخدام",
  brothersSearchPlaceholder: "ابحث عن خادم...",
  brothersEmpty: "لا يوجد خدام",
  brothersEmptySubtitle: "جرب البحث بكلمات مختلفة",

  // More/Profile
  moreTitle: "المزيد",
  personalInfo: "المعلومات الشخصية",
  labelName: "الاسم",
  labelEmail: "البريد الإلكتروني",
  labelPhone: "رقم الهاتف",
  labelGovernment: "المحافظة",
  labelChurch: "الكنيسة",
  labelAccountStatus: "حالة الحساب",
  accountApproved: "معتمد ✓",
  accountPending: "في انتظار الموافقة",
  editProfile: "تعديل الملف الشخصي",
  favoriteGames: "الألعاب المفضلة",
  logout: "تسجيل الخروج",
  changeProfilePicture: "تغيير الصورة الشخصية",
  uploadPhoto: "رفع صورة",
  removePhoto: "إزالة الصورة",
  language: "اللغة",

  // Approval / ID
  pendingApproval: "في انتظار الموافقة",
  pendingApprovalMessage: "حسابك في انتظار الموافقة من المسؤولين. يرجى الانتظار.",
  uploadIdRequired: "مطلوب رفع صورة البطاقة",
  uploadIdMessage: "لم يتم رفع صورة البطاقة الشخصية بعد. يرجى رفعها للمراجعة والموافقة على حسابك.",
  uploadIdAction: "رفع صورة البطاقة",
  pendingApprovalBanner: "حسابك في انتظار الموافقة. بعض المزايا قد تكون محدودة.",
  uploadIdBanner: "يرجى رفع صورة البطاقة الشخصية لتفعيل حسابك.",

  // Favorites
  favoritesTitle: "الألعاب المفضلة",
  favoritesEmpty: "لا توجد ألعاب مفضلة بعد",
  favoritesEmptySubtitle: "يمكنك إضافة الألعاب إلى المفضلة من خلال الضغط على زر الإضافة في صفحة اللعبة.",

  // Auth
  loginTitle: "تسجيل الدخول",
  loginSubtitle: "مرحباً بك مرة أخرى! سجل الدخول للمتابعة",
  signupTitle: "إنشاء حساب جديد",
  forgotPasswordTitle: "نسيت كلمة المرور",
  completeProfileTitle: "استكمال الملف الشخصي",

  // Update profile
  updateProfileTitle: "تعديل الملف الشخصي",
  updateSuccess: "تم تحديث البيانات بنجاح",

  // Form fields
  firstName: "الاسم الأول",
  lastName: "الاسم الأخير",
  email: "البريد الإلكتروني",
  phone: "رقم الهاتف",
  government: "المحافظة",
  churchName: "اسم الكنيسة",
  password: "كلمة المرور",
  confirmPassword: "تأكيد كلمة المرور",
  idFront: "وجه البطاقة",
  idBack: "ظهر البطاقة",
  idVerification: "صور البطاقة للتحقق من الهوية",
};

export type TranslationKeys = keyof typeof ar;
