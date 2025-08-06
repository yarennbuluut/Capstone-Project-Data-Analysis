
		--------- URUN - STOK - SATIS PERFORMANSI ANALIZI ----------

--1.SORU: 
--Her kategoride kaç ürün var?
SELECT
	CATEGORY_NAME,
	COUNT(*) AS TOTAL_PRODUCTS,
	SUM(
		CASE
			WHEN UNIT_IN_STOCK = 0 THEN 1
			ELSE 0
		END
	) AS OUT_OF_STOCK
FROM
	PRODUCTS
	JOIN CATEGORIES USING (CATEGORY_ID)
GROUP BY
	CATEGORY_NAME
	
"	AMAC:
	 -Urun yonetimi ya da stok planlamasi acisindan ongorulerde bulunmak
	 -Veritabanindaki urunlerin kategori bazinda dagilimini inceleyerek, hangi urun kategorilerinin daha fazla urune sahip oldugunu belirlemek
	
	SONUC:
	 -Analiz sonucunda, en fazla urune sahip kategorinin Confections (Sekerlemeler) oldugu gorulmektedir (13 urun). 
	 -Bunu sirasiyla Condiments (Soslar), Beverages (Icecekler) ve Seafood (Deniz Urunleri) kategorileri takip etmektedir (her biri 12 urun ile). 
	 -En az urun bulunan kategoriler ise Produce (Sebze-Meyve) ve Meat/Poultry (Et ve Kumes Hayvanlari) kategorileridir."



--2.SORU:
--Yillara ve aylara gore toplam satislar nelerdir

SELECT
	EXTRACT(YEAR FROM ORDER_DATE) AS ORDER_YEAR,
	EXTRACT(MONTH FROM ORDER_DATE) AS ORDER_MONTH,
	ROUND(SUM(UNIT_PRICE * QUANTITY * (1 - DISCOUNT))::numeric, 2) AS MONTHLY_SALES
FROM
	ORDER_DETAILS
	JOIN ORDERS USING (ORDER_ID)
GROUP BY
	ORDER_YEAR, ORDER_MONTH
ORDER BY
	ORDER_YEAR, ORDER_MONTH 

"   AMAC:
	-Her yılın ve ayın toplam satış gelirlerini hesaplayarak zaman içinde satış performansını analiz etmek. 
	-Bu analiz, mevsimsel dalgalanmaları veya yıl içi satış trendlerini anlamaya yardımcı olur.

	SONUC:
	-Sorgu sonucunda, siparislerin gerceklestigi yil ve aya gore indirimli toplam satis tutarlari elde edilir. 
	-Bu bilgilerle en yogun satis yapilan donemler tespit edilebilir ve pazarlama/uretim stratejileri bu dogrultuda optimize edilebilir."



	
			----- STOK VE KAZANC ANALIZI -----
			
--1.SORU	
-- Stokta hala bulunan ama cok az satilan urunler hangileri
--Not: Bu urunlerin toplam kazanci dusukse, elde kalma riski vardir
WITH
	PRODUCT_SALES AS (
		SELECT
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			P.UNIT_IN_STOCK,
			SUM(OD.QUANTITY) AS TOTAL_QUANTITY_SOLD,
			ROUND(
				SUM(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT))::NUMERIC,
				2
			) AS TOTAL_REVENUE
		FROM
			PRODUCTS P
			LEFT JOIN ORDER_DETAILS OD ON P.PRODUCT_ID = OD.PRODUCT_ID
		GROUP BY
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			P.UNIT_IN_STOCK
	)
SELECT
	PRODUCT_ID,
	PRODUCT_NAME,
	UNIT_IN_STOCK,
	ROUND((TOTAL_REVENUE / UNIT_IN_STOCK),2) AS REVENUE_PER_UNIT,
	TOTAL_QUANTITY_SOLD,
	TOTAL_REVENUE
FROM
	PRODUCT_SALES
WHERE
	UNIT_IN_STOCK > 30
	AND TOTAL_QUANTITY_SOLD < 300
	AND TOTAL_REVENUE < 5000
ORDER BY
	TOTAL_REVENUE ASC;

"	AMAC:
	 - Satis performansi zayif urunleri ortaya cikarmak
	 - Bu urunlerin stokta hala fazla olup olmadigini kontrol etmek
	 - Gerekirse kampanya ya da stok azalimi gibi aksiyonlar planlamak	
	SONUC:
	 - Bu analiz sonucunda, stokta 30 adetten fazla bulunan ancak toplamda 300 adetten az satilan ve 5000 birimden az kazanc getiren urunler belirlenmistir. 
	 - Bu urunler satis acisindan dusuk performans gostermis ve ayni zamanda depoda yer kaplamaya devam etmektedir,
	 - bu yuzden kampanya/indirim uygulamasi veya stok yenilemeyi durdurma gibi acil aksiyonlar alinmalidir."
	


			----- CALISAN PERFORMANSI ANALIZI -----

--1.SORU:
--Her calisan hangi sehirde gorev yapiyor?
SELECT
	FIRST_NAME || ' ' || LAST_NAME AS EMPLOYEE_NAME,
	CITY
FROM
	EMPLOYEES;

"	-AMAC:
		-IK ya da lojistik planlamasi icin kullanilabilecek basit ama ise yarar bir bilgi."


--2.SORU:
-- Hangi calisan, en fazla farkli musteriyle calismis ve hangi calisan bu musterilerden yuksek ortalama gelir saglamis?
WITH
	EMPLOYEE_CUSTOMER_STATS AS (
		SELECT
			E.EMPLOYEE_ID,
			E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME,
			COUNT(DISTINCT O.ORDER_ID) AS TOTAL_ORDERS,
			COUNT(DISTINCT O.CUSTOMER_ID) AS UNIQUE_CUSTOMERS,
			ROUND(
				SUM(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT))::INT,
				2
			) AS TOTAL_REVENUE,
			ROUND(
				AVG(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT))::INT,
				2
			) AS AVG_REVENUE_PER_ORDER
		FROM
			EMPLOYEES E
			JOIN ORDERS O ON E.EMPLOYEE_ID = O.EMPLOYEE_ID
			JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
		GROUP BY
			E.EMPLOYEE_ID,
			EMPLOYEE_NAME
	)
SELECT
	EMPLOYEE_NAME,
	UNIQUE_CUSTOMERS,
	TOTAL_ORDERS,
	TOTAL_REVENUE,
	AVG_REVENUE_PER_ORDER
FROM
	EMPLOYEE_CUSTOMER_STATS
ORDER BY
	UNIQUE_CUSTOMERS DESC,
	AVG_REVENUE_PER_ORDER DESC
LIMIT
	10;

"	AMAC:
	 - Sadece cok siparis alani degil, cok musteri yoneten calisanlari bulmak.
	 - Bu musterilerin calisanla olan etkilesiminden ne kadar ciro sagladigini olcmek.
	 - musteri cesitliligi ve gelir potansiyeli kombinasyonuna gore en guclu calisani gormek.
	SONUC:
	 - Margaret Peaccock, 75 farkli musteriyle ilgilenmis. Bu onu cok yonlu ve guvenilir bir satici yapar.
	 - Ayrica her siparisten ortalama 554 dolar gelir getirmis.
	 - Boyle biri hem satis hacmi hem musteri iliskisi acisindan cok degerlidir.
	 - Prim sistemleri ya da terfi sureclerinde bu kisi one cikarilabilir."


--3.SORU 
--Ortalama sipariş tutarı hangi çalışanlarda daha yüksek?
SELECT
	E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME,
	ROUND(
		AVG(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT))::NUMERIC,
		2
	) AS AVG_ORDER_VALUE --gercek satis geliri icin (1-discount) uygulandi
FROM
	EMPLOYEES E
	JOIN ORDERS O ON E.EMPLOYEE_ID = O.EMPLOYEE_ID
	JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
GROUP BY
	EMPLOYEE_NAME
ORDER BY
	AVG_ORDER_VALUE DESC;

"	AMAC:
	-Her bir calisanin aldigi siparislerin ortalama tutarini hesaplayarak, hangi calisanlarin daha yuksek satis hacmine sahip oldugunu analiz etmek.
 	-Boylece calisanlarin satis performansi hakkinda fikir edinilebilir ve yuksek satis yapan calisanlarin belirli ortak ozellikleri (deneyim, musteri iliskileri, ikna kabiliyeti vb.) uzerine degerlendirme yapilabilir.
	SONUC:
	 -Sorgu sonucunda, bazi calisanlarin ortalama siparis tutarlarinin digerlerine gore belirgin sekilde daha yuksek oldugu gorulmektedir. 
	 -Bu durum, soz konusu calisanlarin daha buyuk veya yuksek degerli siparisleri yonettiklerini gosterebilir.
	 -Bu tur calisanlar, sirketin gelirine dogrudan katki saglayan onemli personeller olarak one cikabilir. 
	 -Ayni zamanda bu veri, performans degerlendirme, prim sistemleri ya da satis stratejilerinin calisan bazinda optimizasyonu icin temel olusturabilir."


			------ MUSTERI SADAKATI VE SIRKET ANALIZI -------

--1.SORU:	
--Bize en cok kâri hangi musteri saglamis ve bu musteriye siparisler ne kadar surede gonderilmis?
WITH
	CUSTOMER_PROFIT AS (
		SELECT
			C.CUSTOMER_ID,
			C.COMPANY_NAME,
			ROUND(
				SUM(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT))::NUMERIC,
				2
			) AS TOTAL_PROFIT,
			ROUND(AVG(O.SHIPPED_DATE - O.ORDER_DATE), 2) AS AVG_SHIPPING_DAYS,
			MAX(SHIPPED_DATE - ORDER_DATE) AS MAX_DELAY,
			SUM(O.ORDER_ID) AS TOTAL_ORDER
		FROM
			CUSTOMERS C
			JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
			JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
		WHERE
			O.SHIPPED_DATE IS NOT NULL
		GROUP BY
			C.CUSTOMER_ID,
			C.COMPANY_NAME
	)
SELECT
	*
FROM
	CUSTOMER_PROFIT
ORDER BY
	TOTAL_PROFIT DESC
LIMIT
	1;

"	-AMAC:
		-En cok kari getiren musteriyi bulmak.
		-Siparislerin gonderim suresinin ortalamsini hesaplamak.
		-Bu musterinin performansini hem gelir hem lojistik yonuyle analiz etmek
	-SONUC:
		-Bu musteri bize 110.277 birim kazandirmis, yani stratejik olarak cok degerli.
		-Siparisler ortalama 10 gunde gonderilmis, bu oldukca makul.
		-Bu musteri icin ozel teklifler, sadakat programi ya da hizli teslim garantisi dusunulebilir."


--2.SORU:
--Her müşterinin toplam sipariş sayısı
SELECT
	C.COMPANY_NAME,
	COUNT(O.ORDER_ID) AS TOTAL_ORDERS
FROM
	CUSTOMERS C
	LEFT JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
GROUP BY
	C.COMPANY_NAME
ORDER BY
	TOTAL_ORDERS DESC;

"	-AMAC:
		-Her musterinin verdigi toplam siparis sayisini belirlemek.

	-SONUC:
		-En cok siparis veren musteriler tespit edilerek sadakat analizi yapilabilir. 
		-Bu veriler, ozel kampanya ve musteri segmentasyonu icin kullanilabilir."




			--------- SEHIR VE SIRKET ANALIZI -------------

--1.SORU:
--En fazla satis yapılan 10 sehir
SELECT
	O.SHIP_CITY,
	ROUND(
		SUM(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT))::NUMERIC,
		2
	) AS TOTAL_SALES
FROM
	ORDERS O
	JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
GROUP BY
	O.SHIP_CITY
ORDER BY
	TOTAL_SALES DESC
LIMIT
	10;

"	-AMAC:
		-Toplam satis tutarina gore en cok satis yapilan 10 sehri belirlemek.

	-SONUC:
		-Sirketin en yuksek geliri bu 10 sehirden geliyor; bu nedenle bu bolgelere odakli pazarlama ve lojistik stratejileri gelistirilebilir."


--2.SORU:
--Her ulkeye ait musteri sayisi
SELECT
	COUNTRY,
	COUNT(*) AS CUSTOMER_COUNT
FROM
	CUSTOMERS
GROUP BY
	COUNTRY
ORDER BY
	CUSTOMER_COUNT DESC;

"	-AMAC:
		-Her ulkede kayitli olan musteri sayisini tespit etmek.

	-SONUC:
		-Musteri dagilimi, hangi ulkelerin pazarlama ve genisleme icin oncelikli oldugunu gosteriyor.