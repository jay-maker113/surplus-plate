# Table 1 - Project Specifications

| Specification         | Details                                                                                  |
|----------------------|------------------------------------------------------------------------------------------|
| Project Name         | Surplus Plate                                                                            |
| Platform             | Mobile (Android, built with Flutter for cross-platform potential)                        |
| Programming Language | Dart (Flutter)                                                                           |
| Development IDE      | Visual Studio Code                                                                       |
| Backend Service      | Firebase (Authentication, Firestore, Cloud Functions)                                   |
| Database             | Firebase Firestore (NoSQL)                                                              |
| Authentication       | Firebase Authentication                                                                 |
| Payment Integration  | Razorpay SDK                                                                            |
| Mapping Service      | OpenStreetMap via Flutter Map Plugin                                                    |
| Image Storage        | Cloudinary                                                                              |
| UI Framework         | Flutter Widgets                                                                         |
| Target Users         | Urban consumers, restaurants, sustainability-conscious users                            |
| Development Duration | 4 months                                                                                |
| Team Size            | 3 members                                                                              |

# Table 2 - Database Collections

| Collection Name | Purpose                          | Key Fields (Document Properties)                                                                                   |
|-----------------|---------------------------------|--------------------------------------------------------------------------------------------------------------------|
| users           | Store user information           | uid, name, email, latitude, longitude, role, createdAt                                                            |
| restaurants     | Store restaurant information     | uid, name, email, role, createdAt                                                                                  |
| food_listings   | Store food surplus listings      | id, restaurant (ref), item, quantity, originalPrice, discountedPrice, latitude, longitude, uploadedBy (ref), imageUrl, timestamp, timeLeft |
| orders          | Store order details (planned)    | id, user (ref), listing (ref), quantity, totalPrice, status, timestamp                                             |
| payments        | Store payment transactions (planned) | id, order (ref), amount, paymentMethod, status, timestamp                                                        |
| feedback        | Store user feedback (planned)    | id, user (ref), restaurant (ref), rating, comments, timestamp                                                     |
