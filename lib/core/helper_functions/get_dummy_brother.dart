import 'package:stepforward/features/home/domain/models/brothers_model.dart';

BrothersModel getDummyBrother() {
  return BrothersModel(
    id: '123456',
    name: 'الاخ اسامة نادي',
    coverUrl:
        'https://img.freepik.com/free-photo/portrait-young-african-american-woman-with-curly-hair_176420-12088.jpg?w=2000',
    phoneNumber: '01288140684',
    tags: ['مرنم'],
    churchName: 'كنيسة العبور الانجيلية',
    government: 'القاهرة',
  );
}
