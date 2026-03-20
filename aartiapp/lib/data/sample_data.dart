import 'models/aarti_item.dart';
import 'models/verse_data.dart';

const List<AartiItem> kAartis = [
  AartiItem(
    title: 'Om Jai Shiv Omkara',
    devanagari: 'ॐ जय शिव ओंकारा',
    deity: 'Shiva',
    duration: '7:32',
    verses: '6 verses',
    isBookmarked: true,
    isOffline: true,
  ),
  AartiItem(
    title: 'Jai Ganesh Deva',
    devanagari: 'जय गणेश देव',
    deity: 'Ganesha',
    duration: '5:14',
    verses: '5 verses',
    isBookmarked: true,
    isOffline: true,
  ),
  AartiItem(
    title: 'Om Jai Lakshmi Mata',
    devanagari: 'ॐ जय लक्ष्मी माता',
    deity: 'Lakshmi',
    duration: '6:02',
    verses: '7 verses',
  ),
  AartiItem(
    title: 'Aarti Kije Hanuman Lala Ki',
    devanagari: 'आरती कीजे हनुमान लला की',
    deity: 'Hanuman',
    duration: '4:45',
    verses: '5 verses',
  ),
  AartiItem(
    title: 'Aarti Kunj Bihari Ki',
    devanagari: 'आरती कुंज बिहारी की',
    deity: 'Krishna',
    duration: '6:30',
    verses: '6 verses',
  ),
  AartiItem(
    title: 'Om Jai Jagdish Hare',
    devanagari: 'ॐ जय जगदीश हरे',
    deity: 'Vishnu',
    duration: '8:15',
    verses: '8 verses',
  ),
];

const List<VerseData> kVerses = [
  VerseData(
    label: 'Dhruva Pad',
    lines: [
      'ॐ जय शिव ओंकारा, स्वामी जय शिव ओंकारा।',
      'ब्रह्मा, विष्णु, सदाशिव, अर्द्धांगी धारा॥',
    ],
    transliteration: [
      'Om Jai Shiv Omkara, Swami Jai Shiv Omkara.',
      'Brahma, Vishnu, Sadashiv, Ardhangee Dhara.',
    ],
    meanings: [
      'Praise be to Lord Shiva, the embodiment of the sacred syllable Om.',
      'Brahma, Vishnu and Sada Shiva — the one who holds his half-body as the divine feminine.',
    ],
  ),
  VerseData(
    label: 'Verse 1',
    lines: [
      'एकानन चतुरानन पञ्चानन राजे।',
      'हंसानन गरुड़ासन वृषवाहन साजे॥',
    ],
    transliteration: [
      'Ekaanan Chaturaanan Panchaanan Raaje.',
      'Hansaanan Garudaasan Vrishavaahan Saaje.',
    ],
    meanings: [
      'The one-faced, four-faced, and five-faced lord reigns supreme.',
      'Riding upon the swan, the eagle and the bull — each form adorned magnificently.',
    ],
  ),
  VerseData(
    label: 'Verse 2',
    lines: [
      'दो भुज चार चतुर्भुज दस भुज अति सोहे।',
      'तीनों रूप निरखते त्रिभुवन जन मोहे॥',
    ],
    transliteration: [
      'Do Bhuj Char Chaturbhuj Das Bhuj Ati Sohe.',
      'Teeno Roop Nirakhte Tribhuvan Jan Mohe.',
    ],
    meanings: [
      'Two-armed, four-armed, ten-armed — each form resplendent in its glory.',
      'Beholding these three forms, all beings of the three worlds are enchanted.',
    ],
  ),
];

const List<Map<String, String>> kDeities = [
  {'emoji': '🕉️', 'label': 'All'},
  {'emoji': '🐘', 'label': 'Ganesha'},
  {'emoji': '🌙', 'label': 'Shiva'},
  {'emoji': '🪷', 'label': 'Lakshmi'},
  {'emoji': '🦚', 'label': 'Krishna'},
  {'emoji': '☀️', 'label': 'Rama'},
  {'emoji': '🌺', 'label': 'Durga'},
  {'emoji': '🌟', 'label': 'Hanuman'},
];
