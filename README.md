# healthApp
🩺 Sağlık Takip Uygulaması

Bu proje, Flutter (Dart) ve Python tabanlı bir sağlık takip mobil uygulamasıdır.
Kullanıcılar kan şekeri ve tansiyon değerlerini girerek kişisel sağlık geçmişlerini takip edebilir,
makine öğrenmesi destekli öneriler alabilir ve chatbot ile temel sağlık sorularına yanıt bulabilir.

🚀 Özellikler

✅ Kan Şekeri Takibi: Girilen kan şekeri ölçümlerini kaydeder, geçmişi listeler ve risk seviyesini analiz eder.

✅ Tansiyon Takibi: 5 günlük tansiyon ölçümlerini kaydeder, ortalamaya göre düşük, normal veya yüksek şeklinde sınıflandırır.

✅ Makine Öğrenmesi ile Tahmin: Python tarafında geliştirilen model sayesinde Tip 2 Diyabet riski tahmini yapılır.

✅ Sağlık Önerileri: Girilen verilere göre kullanıcılara yaşam tarzı ve sağlık önerileri sunar.

✅ Chatbot (Geliştirme Aşamasında): Kullanıcıların temel sağlık sorularına yanıt verir.

✅ Profil Yönetimi: Kullanıcı profil bilgileri güncellenebilir.

✅ Firebase Entegrasyonu:

Kullanıcı kayıt/giriş sistemi

Verilerin bulutta saklanması (Firestore)

Oturum yönetimi

🛠️ Kullanılan Teknolojiler
Teknoloji	Açıklama
Flutter (Dart)	Mobil uygulama arayüzü ve kullanıcı etkileşimi
Python	Makine öğrenmesi modeli (Tip 2 Diyabet tahmini)
scikit-learn, pandas, numpy	Model eğitimi ve veri işleme
Firebase Auth & Firestore	Kimlik doğrulama ve veri saklama
OpenAI/Chatbot altyapısı	Sağlık sorularına yanıt verebilen sohbet botu (geliştirme aşamasında)
📱 Uygulama Ekranları (Örnek)

Buraya ekran görüntülerinizi ekleyebilirsiniz.
Örneğin:

assets/screenshots/home.png
assets/screenshots/history.png

⚡ Kurulum ve Çalıştırma
1️⃣ Flutter Uygulamasını Çalıştırma
# Depoyu klonla
git clone https://github.com/kullaniciadi/saglik-takip.git
cd saglik-takip

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı başlat
flutter run

2️⃣ Python Makine Öğrenmesi Modeli

medical_t5_model.pkl dosyası Flutter tarafından kullanılmak üzere hazırlanmıştır.

Modeli yeniden eğitmek için:

cd ml_model
python train_model.py

     

🔑 Önemli Notlar

Firebase için google-services.json dosyasını kendi projenize göre eklemeniz gerekir.

Python model dosyasını (medical_t5_model.pkl) Flutter içinde kullanılacak dizine yerleştirin.

Chatbot özelliği geliştirme aşamasındadır ve internet bağlantısı gerektirebilir.
