//MESSAGE
import 'package:latlong2/latlong.dart';

final Map<String, LatLng> initialGraphNodes = {
  'wp_Red_Bldg': const LatLng(15.133432099375117, 120.59156597405804), 
  'wp_1': const LatLng(15.133412033142402, 120.59159279614765),
  'wp_2': const LatLng(15.13330976005581, 120.59149087220712),
  'wp_3': const LatLng(15.133335004683044, 120.59146807343093),
  'wp_4': const LatLng(15.133297461390177, 120.59142918140098),
  'wp_SMH_Hall': const LatLng(15.133393261503622, 120.59133195132613),
  'wp_5': const LatLng(15.133365427691336, 120.5912903770872),
  'wp_6': const LatLng(15.133223669381671, 120.59143023257307),
  'wp_7': const LatLng(15.132914806788696, 120.59110631727992),
  'wp_8': const LatLng(15.133294919152528, 120.5907919194499),
  'wp_9': const LatLng(15.13334670300365, 120.59074028692739),
  'wp_SFJ': const LatLng(15.133460479466116, 120.59085284852917),
  'wp_13': const LatLng(15.13359317545732, 120.59104797923104 ),
  'wp_14': const LatLng(15.133855723963597, 120.59076978800937),
  'wp_Entrance': const LatLng(15.134103638384921, 120.5910581254744),
  'wp_15': const LatLng(15.133750214610362, 120.590681945667),
  'wp_16': const LatLng(15.133703609231203, 120.59053107140778),
  'wp_17': const LatLng(15.133532075463707, 120.59056661067531),
  'wp_18': const LatLng(15.133521071406026, 120.590588068347),
  'wp_19': const LatLng(15.133511361942901, 120.59060483215303),
  'wp_20': const LatLng(15.133486117336684, 120.59059879718286),
  'wp_21': const LatLng(15.133460872727467, 120.59058136282462),
  'wp_22': const LatLng(15.133470582192908, 120.59055521128724),
  'wp_23': const LatLng(15.133491295717693, 120.59054247079467),
  'wp_24': const LatLng(15.133517834918365, 120.59054381189914),
  'wp_26': const LatLng(15.133236721227181, 120.59039965251878),
  'wp_27': const LatLng(15.133131584225481, 120.5902918125642),
  'wp_28': const LatLng(15.133655248244608, 120.59037697269471),
  'wp_Main_Bldg': const LatLng(15.133483714439162, 120.5902509088735),
  'wp_30': const LatLng(15.133350371083129, 120.5901020462761),
  'wp_31': const LatLng(15.133004929352413, 120.59041708074746),
  'wp_32': const LatLng(15.133105260689778, 120.59051900468805),
  'wp_33': const LatLng(15.133170637858223, 120.59059209488224),
  'wp_34': const LatLng(15.133178405441255, 120.5906242813898),
  'wp_35': const LatLng(15.133181641934108, 120.59067256115108),
  'wp_36': const LatLng(15.132934373734917, 120.59091261886047),
  'wp_STL': const LatLng(15.13282929770393, 120.59081909615644),
  // 36.5 (15.132706903706893, 120.59091638206885)
  'wp_37': const LatLng(15.132817859825359, 120.59102661274136),
  'wp_38': const LatLng(15.132633567440882, 120.59084965045395),
  // 38.5 (15.13223692043222, 120.5904536490036)
  'wp_39': const LatLng(15.132757558392683, 120.5907124427148),
  // 39.5 (15.13239547116539, 120.59033390838937)
  'wp_PGN': const LatLng(15.132680310555097, 120.59064176593338),
  'wp_40': const LatLng(15.132160633318056, 120.59036448709348),
  'wp_41': const LatLng(15.132134122127566, 120.59034284304455),
  'wp_42': const LatLng(15.13203758898817, 120.5904679045169),
  'wp_GGN': const LatLng(15.131774801467255, 120.59076002493137),
  'wp_SMH': const LatLng(15.132345931884226, 120.59076382367842),
  'wp_SRH': const LatLng(15.132467533909812, 120.59090335969495),
  'wp_SGH': const LatLng(15.132577911072623, 120.59100801170736),
  'wp_Yellow_Canteen': const LatLng(15.132692029773716, 120.59110684971908),
  'wp_Warehouse': const LatLng(15.132830929070055, 120.59124105841249),
  'wp_44': const LatLng(15.132535202857468, 120.5900208483946),
  // 44.5 (15.13260298914833, 120.59009433575467)
  'wp_45': const LatLng(15.132817382868094, 120.59029683426392),
  'wp_46': const LatLng(15.132982956647934, 120.590128313279),
  'wp_47': const LatLng(15.132825739025238, 120.58978773663993),
  'wp_MGN': const LatLng(15.13279349446057, 120.58976294933748),
  'wp_48': const LatLng(15.132707582456803, 120.5898434570567),
  'wp_49': const LatLng(15.13264961802034, 120.58977515806673),
  'wp_50': const LatLng(15.13257239847894, 120.5898451142205),
  'wp_Chapel': const LatLng(15.132341064922214, 120.58962344859127),
  'wp_51': const LatLng(15.132477491169965, 120.58994034343245),
  'wp_52': const LatLng(15.132352992979364, 120.59002266485278),
  'wp_53': const LatLng(15.13224760572798, 120.59004340558988),
  'wp_54': const LatLng(15.132142736233854, 120.59002998859549),
  'wp_55': const LatLng(15.131974918751, 120.58992224300285),
  'wp_APS': const LatLng(15.131883465545998, 120.5900520880617),
  'wp_56': const LatLng(15.131856442742675, 120.58976797262379),
  'wp_57': const LatLng(15.131820150121083, 120.58963925357362),
  'wp_58': const LatLng(15.13184455323221, 120.58948219546502),
  'wp_59': const LatLng(15.131978522450783, 120.58931012798753),
  'wp_Foundation': const LatLng(15.132013073526661, 120.58934328877164),
  'wp_61': const LatLng(15.131881549438718, 120.58909452576523),
  'wp_62': const LatLng(15.131852057697255, 120.58912704905417),
  'wp_Covered_Court': const LatLng(15.13183761977927, 120.58914646827404),
  'wp_63': const LatLng(15.131881399497779, 120.5891572148703),
  'wp_64': const LatLng(15.131399925235911, 120.5896077996802),
  'wp_SH': const LatLng(15.13137840427564, 120.58958347222962),
  'wp_65': const LatLng(15.131865871770888, 120.59007307291422),
  'wp_66': const LatLng(15.131981831082395, 120.58900917654769),
  'wp_IH_Gym': const LatLng(15.131901819328327, 120.5889242196721),
  // 66.5 (15.132272639959258, 120.58872017796385)
  'wp_Annex': const LatLng(15.132294244897215, 120.58869931407396),
  'wp_SJH': const LatLng(15.132651609757776, 120.58917318509822),
  'wp_67': const LatLng(15.132020327708398, 120.58925496836859),
  'wp_69': const LatLng(15.132214579518845, 120.58908504115774),
  'wp_70': const LatLng(15.13226843073766, 120.5890763214839),
  'wp_71': const LatLng(15.13230154985609, 120.58909541513563),
  'wp_72': const LatLng(15.132590886720097, 120.58941209058894),
  'wp_73': const LatLng(15.132691027992806, 120.58946231590312),
  'wp_74': const LatLng(15.132766410024384, 120.58951475651067  ),
  'wp_75': const LatLng(15.132779840264961, 120.58958950747545),
  'wp_76': const LatLng(15.132753056189989, 120.58965772494898),
  // 77 (15.132948553477506, 120.58952006062535)
  // 78 (15.133019834028932, 120.58959730443848)

};

final Map<String, Map<String, double>> initialGraphEdges = () {
  final dist = Distance();
  final Map<String, Map<String, double>> edges = {};

  void connect(String a, String b) {
    edges.putIfAbsent(a, () => {});
    edges.putIfAbsent(b, () => {});
    final d = dist.as(LengthUnit.Meter, initialGraphNodes[a]!, initialGraphNodes[b]!);
    edges[a]![b] = d;
    edges[b]![a] = d;
  }

  connect('wp_Red_Bldg', 'wp_1');
  connect('wp_1', 'wp_2');
  connect('wp_2', 'wp_3');
  connect('wp_3', 'wp_4');
  connect('wp_4', 'wp_SMH_Hall');
  connect('wp_SMH_Hall', 'wp_5');
  connect('wp_5', 'wp_6');
  connect('wp_6', 'wp_7');
  connect('wp_7', 'wp_8');
  connect('wp_8', 'wp_9');
  connect('wp_12', 'wp_SFJ'); // 9 to SFJ
  connect('wp_SFJ', 'wp_13');
  connect('wp_13', 'wp_5');
  connect('wp_13', 'wp_14');
  connect('wp_14', 'wp_Entrance');
  connect('wp_14', 'wp_15');
  connect('wp_15', 'wp_16');
  connect('wp_16', 'wp_17');
  connect('wp_17', 'wp_18');
  connect('wp_18', 'wp_19');
  connect('wp_19', 'wp_20');
  connect('wp_20', 'wp_12'); // 20 to 8
  connect('wp_20', 'wp_21');
  connect('wp_21', 'wp_22');
  connect('wp_22', 'wp_23');
  connect('wp_23', 'wp_24');
  connect('wp_24', 'wp_25'); // 24 to 17
  connect('wp_24', 'wp_26');
  connect('wp_26', 'wp_27');
  connect('wp_27', 'wp_30');
  connect('wp_28', 'wp_16');
  connect('wp_Main_Bldg', 'wp_29'); // Main Building to 28
  connect('wp_30', 'wp_Main_Bldg');
  connect('wp_31', 'wp_27');
  connect('wp_31', 'wp_32');
  connect('wp_32', 'wp_26');
  connect('wp_32', 'wp_33');
  connect('wp_33', 'wp_34');
  connect('wp_34', 'wp_35');
  connect('wp_35', 'wp_8');
  connect('wp_35', 'wp_36');
  //  36 to STL
  connect('wp_36', 'wp_37');
  // 36 to STL
  //  STL to 36.5
  //  36.5 to 38
  connect('wp_37', 'wp_7');
  // 38 to 39
  connect('wp_39', 'wp_31');
  connect('wp_39', 'wp_PGN');
  // PGN to 39.5
  connect('wp_40', 'wp_38'); //38.5 to 38
  // 38.5 to 40
  connect('wp_40', 'wp_41');
  connect('wp_41', 'wp_42');
  connect('wp_42', 'wp_GGN');
  connect('wp_42', 'wp_SMH');
  connect('wp_SMH', 'wp_SRH');
  connect('wp_SRH', 'wp_SGH');
  connect('wp_SRH', 'wp_38');
  connect('wp_SGH', 'wp_Yellow_Canteen');
  connect('wp_Yellow_Canteen', 'wp_Warehouse');
  connect('wp_Yellow_Canteen', 'wp_37');
  connect('wp_43', 'wp_40'); //44 to 40
  connect('wp_44', 'wp_45'); //44 to 44.5
  //44.5 to 45
  connect('wp_45', 'wp_31');
  connect('wp_45', 'wp_46');
  connect('wp_46', 'wp_27');
  connect('wp_46', 'wp_47'); //46 to 48
  connect('wp_47', 'wp_MGN'); // 48 to MGN
  // MGN to 47
  // 48 to 44
  connect('wp_48', 'wp_49');
  connect('wp_49', 'wp_50');
  connect('wp_50', 'wp_Chapel');
  connect('wp_50', 'wp_51');
  connect('wp_51', 'wp_52');
  connect('wp_52', 'wp_53');
  connect('wp_53', 'wp_54');
  connect('wp_54', 'wp_55');
  connect('wp_55', 'wp_APS');
  connect('wp_55', 'wp_56');
  connect('wp_56', 'wp_57');
  connect('wp_57', 'wp_58');
  connect('wp_58', 'wp_59');
  connect('wp_60', 'wp_Foundation'); //59 to Foundation
  connect('wp_60', 'wp_61'); //59 to 61
  connect('wp_61', 'wp_62');
  connect('wp_62', 'wp_Covered_Court');
  connect('wp_62', 'wp_63');
  connect('wp_63', 'wp_64');
  connect('wp_64', 'wp_SH');
  connect('wp_64', 'wp_65');
  connect('wp_65', 'wp_APS');
  connect('wp_65', 'wp_41');
  connect('wp_66', 'wp_61');
  connect('wp_66', 'wp_IH_Gym');
  connect('wp_66', 'wp_Annex'); //66 to 66.5
  //66.5 to Annex
  connect('wp_Annex', 'wp_SJH'); //66.5 to SJH
  connect('wp_67', 'wp_60');
  connect('wp_67', 'wp_68'); // 67 to 69
  connect('wp_69', 'wp_70');
  connect('wp_70', 'wp_71');
  connect('wp_71', 'wp_72');
  connect('wp_72', 'wp_73');
  connect('wp_73', 'wp_74');
  // 74 - 75
  connect('wp_75', 'wp_76');
  // 76 - 77
  // 77 - SJH
  // 77 - 78
  // 78 - 47

  return edges;
}();

final Map<String, List<String>> buildingToWaypoints = {
  'Peter G. Nepomuceno Building (PGN)': ['wp_PGN'],
  'Geromin G. Nepomuceno Building (GGN)': ['wp_GGN'],
  'Don Juan D. Nepomuceno Building (DJDN / Main Bldg.)': ['wp_Main_Bldg'],
  'Plaza De Corazon Building (Red Bldg.)': ['wp_Red_Bldg'],
  'St. Martha Hall Building': ['wp_SMH_Hall'],
  'San Francisco De Javier Building (SFJ)': ['wp_SFJ'],
  'St. Therese of Liseux Building (STL)': ['wp_STL'],
  'Warehouse & Carpentry': ['wp_Warehouse'],
  'Yellow Food Court': ['wp_Yellow_Canteen'],
  'St. Gabriel Hall Building (SGH)': ['wp_SGH'],
  'St. Raphael Hall Building (SRH)': ['wp_SRH'],
  'St. Michael Hall Building (SMH)': ['wp_SMH'],
  'Archbishop Pedro Santos Building (APS)': ['wp_APS'],
  'Mamerto G. Nepomuceno Building (MGN)': ['wp_MGN'],
  'Chapel of the Holy Guardian Angel': ['wp_Chapel'],
  'Sister Josefina Nepomuceno Formation Center': ['wp_Foundation'],
  'St. Joseph Hall Building (SJH)': ['wp_SJH'],
  'Sacred Heart Building (SH)': ['wp_SH'],
  'Covered Court': ['wp_Covered_Court'],
  'Immaculate Heart Gymnasium': ['wp_IH_Gym'],
  'Immaculate Heart Gymnasium Annex': ['wp_Annex'],
  'Entrance': ['wp_Entrance']
};
final List<String> initialGraphNodeKeys = [
  'wp_Entrance',
  'wp_Red_Bldg',
  'wp_SMH_Hall',
  'wp_SFJ',
  'wp_STL',
  'wp_Warehouse',
  'wp_Yellow_Canteen',
  'wp_SGH',
  'wp_SRH',
  'wp_SMH',
  'wp_GGN',
  'wp_PGN',
  'wp_Main_Bldg',
  'wp_APS',
  'wp_MGN',
  'wp_Chapel',
  'wp_Foundation',
  'wp_SJH',
  'wp_SH',
  'wp_Covered_Court',
  'wp_IH_Gym',
  'wp_Annex',
  'wp_1', 'wp_2', 'wp_3', 'wp_4', 'wp_5', 'wp_6', 'wp_7', 'wp_8', 'wp_9', 'wp_10',
  'wp_11', 'wp_12', 'wp_13', 'wp_14', 'wp_15', 'wp_16', 'wp_17', 'wp_18', 'wp_19', 'wp_20',
  'wp_21', 'wp_22', 'wp_23', 'wp_24', 'wp_25', 'wp_26', 'wp_27', 'wp_28', 'wp_29', 'wp_30',
  'wp_31', 'wp_32', 'wp_33', 'wp_34', 'wp_35', 'wp_36', 'wp_37', 'wp_38', 'wp_39', 'wp_40',
  'wp_41', 'wp_42', 'wp_43', 'wp_44', 'wp_45', 'wp_46', 'wp_47', 'wp_48', 'wp_49', 'wp_50',
  'wp_51', 'wp_52', 'wp_53', 'wp_54', 'wp_55', 'wp_56', 'wp_57', 'wp_58', 'wp_59', 'wp_60',
  'wp_61', 'wp_62', 'wp_63', 'wp_64', 'wp_65', 'wp_66', 'wp_67', 'wp_68', 'wp_69', 'wp_70',
  'wp_71', 'wp_72', 'wp_73', 'wp_74', 'wp_75', 'wp_76',
];
