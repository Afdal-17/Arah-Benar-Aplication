import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/doa_model.dart';

class DoaRepository {
  Future<List<Doa>> fetchDoa() async {
    try {
      // Try primary API first
      final primaryUrl = 'https://doa-doa-api-ahmadramadhan.fly.dev/api';
      final url = kIsWeb
          ? 'https://api.allorigins.win/raw?url=$primaryUrl'
          : primaryUrl;

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded
              .where((e) => e is Map<String, dynamic>)
              .map((e) => Doa.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      // If primary fails, use fallback
      return _fallbackDoa();
    } catch (e) {
      debugPrint('Error fetch doa: $e');
      // Return fallback data on any error
      return _fallbackDoa();
    }
  }

  /// Fallback: embedded doa data so the page never shows "gagal memuat"
  List<Doa> _fallbackDoa() {
    final data = [
      {
        'id': '1',
        'doa': 'Doa sebelum tidur',
        'ayat': 'بِسْمِكَ اللّٰهُمَّ اَحْيَا وَبِاسْمِكَ اَمُوْتُ',
        'latin': 'Bismikallaahumma ahyaa wa ammuut',
        'artinya': 'Dengan menyebut nama Allah, aku hidup dan aku mati',
      },
      {
        'id': '2',
        'doa': 'Doa bangun tidur',
        'ayat':
            'اَلْحَمْدُ لِلَّهِ الَّذِيْ اَحْيَانَا بَعْدَمَا اَمَاتَنَا وَاِلَيْهِ النُّشُوْرُ',
        'latin':
            'Alhamdu lillahil ladzii ahyaanaa ba\'da maa amaatanaa wa ilahin nusyuuru',
        'artinya':
            'Segala puji bagi Allah yang telah menghidupkan kami sesudah kami mati dan hanya kepada-Nya kami dikembalikan',
      },
      {
        'id': '3',
        'doa': 'Doa masuk kamar mandi',
        'ayat':
            'اَللّٰهُمَّ اِنِّيْ اَعُوْذُبِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
        'latin':
            'Allahumma Innii a\'uudzubika minal khubutsi wal khobaaitsi',
        'artinya':
            'Ya Allah, aku berlindung pada-Mu dari godaan setan laki-laki dan setan perempuan',
      },
      {
        'id': '4',
        'doa': 'Doa keluar rumah',
        'ayat':
            'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لاَحَوْلَ وَلاَقُوَّةَ اِلاَّ بِاللَّهِ',
        'latin':
            'Bismillaahi tawakkaltu \'alalloohi laa hawlaa walaa quwwata illaa bilaahi',
        'artinya':
            'Dengan menyebut nama Allah aku bertawakal kepada Allah, tiada daya dan kekuatan melainkan dengan pertolongan Allah',
      },
      {
        'id': '5',
        'doa': 'Doa masuk rumah',
        'ayat':
            'اَللّٰهُمَّ اِنِّيْ اَسْأَلُكَ خَيْرَالْمَوْلِجِ وَخَيْرَالْمَخْرَجِ بِسْمِ اللَّهِ وَلَجْنَا وَبِسْمِ اللَّهِ خَرَجْنَا وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
        'latin':
            'Allahumma innii as-aluka khoirol mauliji wa khoirol makhroji bismillaahi wa lajnaa wa bismillaahi khorojnaa wa\'alallohi robbinaa tawakkalnaa',
        'artinya':
            'Ya Allah, sesungguhnya aku mohon kepada-Mu baiknya tempat masuk dan baiknya tempat keluar',
      },
      {
        'id': '6',
        'doa': 'Doa sebelum belajar',
        'ayat': 'يَارَبِّ زِدْنِيْ عِلْمًا وَارْزُقْنِيْ فَهْمًا',
        'latin': 'Yaa robbi zidnii \'ilman warzuqnii fahmaa',
        'artinya':
            'Ya Allah, tambahkanlah aku ilmu dan berikanlah aku rizqi akan kepahaman',
      },
      {
        'id': '7',
        'doa': 'Doa sesudah belajar',
        'ayat':
            'اَللّٰهُمَّ اِنِّيْ اِسْتَوْدِعُكَ مَاعَلَّمْتَنِيْهِ فَارْدُدْهُ اِلَيَّ عِنْدَ حَاجَتِيْ',
        'latin':
            'Allaahumma innii astaudi\'uka maa \'allamtaniihi fardud-hu ilayya \'inda haajatii',
        'artinya':
            'Ya Allah, sesungguhnya aku menitipkan kepada-Mu ilmu yang telah Engkau ajarkan kepadaku, kembalikanlah kepadaku sewaktu aku membutuhkannya',
      },
      {
        'id': '8',
        'doa': 'Doa sebelum makan',
        'ayat':
            'اَللّٰهُمَّ بَارِكْ لَنَا فِيْمَا رَزَقْتَنَا وَقِنَا عَذَابَ النَّارِ',
        'latin':
            'Allahumma baarik lanaa fiimaa rozaqtanaa wa qinaa \'adzaa bannaar',
        'artinya':
            'Ya Allah, berkahilah kami dalam rezeki yang telah Engkau berikan kepada kami dan peliharalah kami dari siksa api neraka',
      },
      {
        'id': '9',
        'doa': 'Doa sesudah makan',
        'ayat':
            'اَلْحَمْدُ لِلَّهِ الَّذِيْ اَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِيْنَ',
        'latin':
            'Alhamdulillahilladzi ath-amanaa wa saqoonaa wa ja\'alanaa minal muslimiin',
        'artinya':
            'Segala puji bagi Allah yang telah memberi kami makan dan minum serta menjadikan kami termasuk kaum muslimin',
      },
      {
        'id': '10',
        'doa': 'Doa sebelum wudhu',
        'ayat':
            'نَوَيْتُ الْوُضُوْءَ لِرَفْعِ الْحَدَثِ الْاَصْغَرِ فَرْضًا لِلّٰهِ تَعَالَى',
        'latin':
            'Nawaitul whudu-a lirof\'il hadatsii ashghori fardhon lillaahi ta\'aalaa',
        'artinya':
            'Saya niat berwudhu untuk menghilangkan hadast kecil fardu (wajib) karena Allah ta\'ala',
      },
      {
        'id': '11',
        'doa': 'Doa sesudah wudhu',
        'ayat':
            'اَشْهَدُ اَنْ لاَّ اِلَهَ اِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيْكَ لَهُ وَاَشْهَدُ اَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُوْلُهُ',
        'latin':
            'Asyhadu allaa ilaaha illalloohu wahdahuu laa syariika lahu wa asyhadu anna muhammadan \'abduhuuwa rosuuluhuu',
        'artinya':
            'Aku bersaksi, tidak ada Tuhan selain Allah Yang Maha Esa, tidak ada sekutu bagi-Nya, dan aku mengaku bahwa Nabi Muhammad itu adalah hamba dan Utusan Allah',
      },
      {
        'id': '12',
        'doa': 'Doa naik kendaraan',
        'ayat':
            'سُبْحَانَ الَّذِيْ سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِيْنَ وَاِنَّا اِلَى رَبِّنَا لَمُنْقَلِبُوْنَ',
        'latin':
            'Subhaanal ladzii sakhkhoro lanaa haadzaa wamaa kunnaa lahuu muqriniin. Wa innaa ilaa robbinaa lamunqolibuun',
        'artinya':
            'Mahasuci Dia yang telah menundukkan semua ini bagi kami padahal sebelumnya kami tidak mampu menguasainya. Dan sesungguhnya kami akan kembali kepada Tuhan kami',
      },
      {
        'id': '13',
        'doa': 'Doa masuk masjid',
        'ayat': 'اللَّهُمَّ افْتَحْ لِيْ اَبْوَابَ رَحْمَتِكَ',
        'latin': 'Alloohummaf tahlii abwaaba rohmatik',
        'artinya':
            'Ya Allah, bukakanlah pintu-pintu rahmat-Mu untukku',
      },
      {
        'id': '14',
        'doa': 'Doa keluar masjid',
        'ayat': 'اللَّهُمَّ اِنِّيْ اَسْأَلُكَ مِنْ فَضْلِكَ',
        'latin': 'Alloohumma innii as-aluka min fadllik',
        'artinya':
            'Ya Allah, sesungguhnya aku memohon keutamaan kepada-Mu',
      },
      {
        'id': '15',
        'doa': 'Doa setelah adzan',
        'ayat':
            'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلاَةِ الْقَائِمَةِ اٰتِ مُحَمَّدًا الْوَسِيْلَةَ وَالْفَضِيْلَةَ',
        'latin':
            'Alloohumma robba haadzihid da\'watit taammah washsholaatil qoo-imah. Aati Muhammadanil wasiilata wal fadliilah',
        'artinya':
            'Ya Allah, Tuhan pemilik panggilan yang sempurna dan shalat yang akan didirikan ini, berikanlah wasilah dan keutamaan kepada Muhammad',
      },
      {
        'id': '16',
        'doa': 'Doa ketika turun hujan',
        'ayat': 'اللَّهُمَّ صَيِّبًا نَافِعًا',
        'latin': 'Allahumma shayyiban nafi\'an',
        'artinya':
            'Ya Allah, curahkanlah air hujan yang bermanfaat (HR Bukhari)',
      },
      {
        'id': '17',
        'doa': 'Doa memohon ilmu bermanfaat',
        'ayat':
            'اَللّٰهُمَّ اِنِّيْ اَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلاً مُتَقَبَّلاً',
        'latin':
            'Allahumma innii as-aluka \'ilmaan naafi\'aan wa rizqoon thoyyibaan wa \'amalaan mutaqobbalaan',
        'artinya':
            'Ya Allah, sesungguhnya aku mohon kepada-Mu ilmu yang berguna, rezki yang baik dan amal yang diterima (HR Ibnu Majah)',
      },
      {
        'id': '18',
        'doa': 'Doa agar dicukupkan rezeki',
        'ayat':
            'اَللّٰهُمَّ اَكْفِنِيْ بِحَلَالِكَ عَنْ حَرَامِكَ وَاَغْنِنِيْ بِفَضْلِكَ عَمَّنْ سِوَاكَ',
        'latin':
            'Allahummakfini bihalalika \'an haramik wa aghnini bifadhlika amman siwak',
        'artinya':
            'Ya Allah, berilah aku kecukupan dengan rezeki yang halal dan berilah aku kekayaan dengan karunia-Mu (HR Ahmad)',
      },
      {
        'id': '19',
        'doa': 'Doa memakai pakaian',
        'ayat':
            'بِسْمِ اللَّهِ اَللّٰهُمَّ اِنِّيْ اَسْأَلُكَ مِنْ خَيْرِهِ وَخَيْرِ مَاهُوَ لَهُ',
        'latin':
            'Bismillaahi, Alloohumma innii as-aluka min khoirihi wa khoiri maa huwa lahuu',
        'artinya':
            'Dengan nama-Mu ya Allah, aku minta kepada Engkau kebaikan pakaian ini',
      },
      {
        'id': '20',
        'doa': 'Doa untuk kedua orang tua',
        'ayat':
            'رَبِّ اغْفِرْلِيْ وَلِوَالِدَيَّ وَارْحَمْهُمَا كَمَا رَبَّيَانِيْ صَغِيْرًا',
        'latin':
            'Rabbighfirlii waliwalidayya warhamhumaa kamaa robbayaanii shaghiiroo',
        'artinya':
            'Ya Tuhanku, ampunilah aku dan kedua orang tuaku, sayangilah mereka sebagaimana mereka menyayangiku di waktu kecil',
      },
    ];

    return data.map((e) => Doa.fromJson(e)).toList();
  }
}