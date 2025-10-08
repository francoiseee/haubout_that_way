// Waypoints and example pathway edges for HAU campus
// - `initialGraphNodes` contains named waypoint LatLngs you can edit or extend.
// - `initialGraphEdges` contains distances between those waypoint nodes.
//   These are example intra-waypoint edges; edges that connect to building
//   nodes should be added in `map_page.dart` after merging nodes.

import 'package:latlong2/latlong.dart';

final Map<String, LatLng> initialGraphNodes = {
  'wp_Red_Bldg': const LatLng(15.133481,120.591565), 
  'wp_1': const LatLng(15.133432,120.591613),
  'wp_2': const LatLng(15.133354,120.591530),
  'wp_3': const LatLng(15.133400,120.591471),
  'wp_4': const LatLng(15.133346,120.591425),
  'wp_SMH_Hall': const LatLng(15.133413,120.591356),
  'wp_5': const LatLng(15.133359,120.591289),
  'wp_6': const LatLng(15.133222,120.591441),
  'wp_7': const LatLng(15.132883,120.591120),
  'wp_8': const LatLng(15.133222,120.590760),
  'wp_9': const LatLng(15.133245,120.590731),
  'wp_10': const LatLng(15.133274,120.590731),
  'wp_11': const LatLng(15.133315,120.590704),
  'wp_12': const LatLng(15.133343,120.590744),
  'wp_SFJ': const LatLng(15.133476,120.590910),
  'wp_13': const LatLng(15.133592,120.591039),
  'wp_14': const LatLng(15.133861,120.590811),
  'wp_Entrance': const LatLng(15.134110,120.591074),
  'wp_15': const LatLng(15.133758,120.590733),
  'wp_16': const LatLng(15.133711,120.590562),
  'wp_17': const LatLng(15.133470,120.590596),
  'wp_18': const LatLng(15.133460,120.590645),
  'wp_19': const LatLng(15.133429,120.590669),
  'wp_20': const LatLng(15.133395,120.590661),
  'wp_21': const LatLng(15.133359,120.590631),
  'wp_22': const LatLng(15.133349,120.590583),
  'wp_23': const LatLng(15.133380,120.590548),
  'wp_24': const LatLng(15.133416,120.590537),
  'wp_25': const LatLng(15.133444,120.590546),
  'wp_26': const LatLng(15.133242,120.590457),
  'wp_27': const LatLng(15.133134,120.590352),
  'wp_28': const LatLng(15.133659,120.590377),
  'wp_29': const LatLng(15.133556,120.590315),
  'wp_Main_Bldg': const LatLng(15.133504,120.590237),
  'wp_30': const LatLng(15.133400,120.590098),
  'wp_31': const LatLng(15.133053,120.590438),
  'wp_32': const LatLng(15.133154,120.590551),
  'wp_33': const LatLng(15.133157,120.590605),
  'wp_34': const LatLng(15.133162,120.590661),
  'wp_35': const LatLng(15.133178,120.590709),
  'wp_36': const LatLng(15.132867,120.591039),
  'wp_37': const LatLng(15.132833,120.591069),
  'wp_38': const LatLng(15.132673,120.590833),
  'wp_STL': const LatLng(15.132725,120.590782),
  'wp_39': const LatLng(15.132950,120.590529),
  'wp_PGN': const LatLng(15.132896,120.590462),
  'wp_40': const LatLng(15.132186,120.590395),
  'wp_41': const LatLng(15.132158,120.590366),
  'wp_42': const LatLng(15.132041,120.590460),
  'wp_GGN': const LatLng(15.131868,120.590666),
  'wp_SMH': const LatLng(15.132375,120.590819),
  'wp_SRH': const LatLng(15.132510,120.590943),
  'wp_SGH': const LatLng(15.132606,120.591031),
  'wp_Yellow_Canteen': const LatLng(15.132709,120.591195),
  'wp_Warehouse': const LatLng(15.132813,120.591278),
  'wp_43': const LatLng(15.132554,120.590041),
  'wp_44': const LatLng(15.132624,120.589953),
  'wp_45': const LatLng(15.132841,120.590186),
  'wp_46': const LatLng(15.132919,120.590132),
  'wp_47': const LatLng(15.132751,120.589929),
  'wp_MGN': const LatLng(15.132849,120.589848),
  'wp_48': const LatLng(15.132704,120.589875),
  'wp_49': const LatLng(15.132629,120.589784),
  'wp_50': const LatLng(15.132587,120.589824),
  'wp_Chapel': const LatLng(15.132406,120.589615),
  'wp_51': const LatLng(15.132468,120.589942),
  'wp_52': const LatLng(15.132380,120.590001),
  'wp_53': const LatLng(15.132230,120.590041),
  'wp_54': const LatLng(15.132083,120.590006),
  'wp_55': const LatLng(15.131995,120.589931),
  'wp_APS': const LatLng(15.131932,120.589993),
  'wp_56': const LatLng(15.131875,120.589765),
  'wp_57': const LatLng(15.131798,120.589609),
  'wp_58': const LatLng(15.131862,120.589465),
  'wp_59': const LatLng(15.131953,120.589304),
  'wp_60': const LatLng(15.132039,120.589186),
  'wp_Foundation': const LatLng(15.132093,120.589263),
  'wp_61': const LatLng(15.131938,120.589068),
  'wp_62': const LatLng(15.131883,120.589111),
  'wp_Covered_Court': const LatLng(15.131862,120.589127),
  'wp_63': const LatLng(15.131919,120.589137),
  'wp_64': const LatLng(15.131464,120.589591),
  'wp_SH': const LatLng(15.131427,120.589545),
  'wp_65': const LatLng(15.131881,120.590060),
  'wp_66': const LatLng(15.132018,120.589006),
  'wp_IH_Gym': const LatLng(15.131961,120.588944),
  'wp_Annex': const LatLng(15.132334,120.588711),
  'wp_SJH': const LatLng(15.132730,120.589170),
  'wp_67': const LatLng(15.132261,120.589033),
  'wp_68': const LatLng(15.132543,120.589427),
  'wp_69': const LatLng(15.132624,120.589432),
  'wp_70': const LatLng(15.132699,120.589443),
  'wp_71': const LatLng(15.132753,120.589532),
  'wp_72': const LatLng(15.132769,120.589609),
  'wp_73': const LatLng(15.132751,120.589674),
  'wp_74': const LatLng(15.132688,120.589711),
  'wp_75': const LatLng(15.133004,120.589494),
  'wp_76': const LatLng(15.133069,120.589601),
};

// Pre-compute distances between the example waypoint nodes. These edges are
// only between the waypoint nodes themselves. Map edges connecting waypoints
// to buildings are added in `map_page.dart` so they can reference building
// node coordinates there.
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
  connect('wp_9', 'wp_10');
  connect('wp_10', 'wp_11');
  connect('wp_11', 'wp_12');
  connect('wp_12', 'wp_SFJ');
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
  connect('wp_20', 'wp_12');
  connect('wp_20', 'wp_21');
  connect('wp_21', 'wp_22');
  connect('wp_22', 'wp_23');
  connect('wp_23', 'wp_24');
  connect('wp_24', 'wp_25');
  connect('wp_24', 'wp_26');
  connect('wp_25', 'wp_17');
  connect('wp_26', 'wp_27');
  connect('wp_27', 'wp_30');
  connect('wp_28', 'wp_16');
  connect('wp_29', 'wp_28');
  connect('wp_Main_Bldg', 'wp_29');
  connect('wp_30', 'wp_Main_Bldg');
  connect('wp_31', 'wp_27');
  connect('wp_31', 'wp_32');
  connect('wp_32', 'wp_26');
  connect('wp_32', 'wp_33');
  connect('wp_33', 'wp_34');
  connect('wp_34', 'wp_35');
  connect('wp_35', 'wp_8');
  connect('wp_35', 'wp_36');
  connect('wp_36', 'wp_37');
  connect('wp_36', 'wp_38');
  connect('wp_37', 'wp_7');
  connect('wp_38', 'wp_STL');
  connect('wp_39', 'wp_STL');
  connect('wp_39', 'wp_31');
  connect('wp_39', 'wp_PGN');
  connect('wp_40', 'wp_38');
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
  connect('wp_43', 'wp_40');
  connect('wp_43', 'wp_PGN');
  connect('wp_43', 'wp_44');
  connect('wp_44', 'wp_45');
  connect('wp_45', 'wp_31');
  connect('wp_45', 'wp_46');
  connect('wp_46', 'wp_27');
  connect('wp_46', 'wp_47');
  connect('wp_47', 'wp_MGN');
  connect('wp_47', 'wp_48');
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
  connect('wp_59', 'wp_60');
  connect('wp_60', 'wp_Foundation');
  connect('wp_60', 'wp_61');
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
  connect('wp_66', 'wp_Annex');
  connect('wp_Annex', 'wp_SJH');
  connect('wp_67', 'wp_60');
  connect('wp_67', 'wp_68');
  connect('wp_68', 'wp_69');
  connect('wp_69', 'wp_70');
  connect('wp_70', 'wp_71');
  connect('wp_71', 'wp_72');
  connect('wp_72', 'wp_73');
  connect('wp_73', 'wp_74');
  connect('wp_74', 'wp_49');
  connect('wp_75', 'wp_73');
  connect('wp_75', 'wp_SJH');
  connect('wp_75', 'wp_76');
  connect('wp_76', 'wp_MGN');

  return edges;
}();

// Optional: map of building node names (as they appear in map_page.dart) to
// nearby waypoint node keys. Use this to automatically connect buildings to
// the waypoint network. Edit these mappings to match the nearest waypoint
// to each building for realistic routing.
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
  ' Entrance': ['wp_Entrance'],
};

// You can edit `initialGraphNodes` to add new waypoint nodes and the
// initializer above will automatically add example edges between the listed
// nodes. For a production pedestrian graph, prefer hand-curated waypoint
// lists and explicit edges (both directions) to match sidewalks and crossings.

// Ordered list of waypoint keys. Use this to render stable numeric IDs on the
// map (1..N). Keep the order intentional: change this list when you add new
// waypoints to preserve predictable numbering used in the UI.
final List<String> initialGraphNodeKeys = [
  // Main building waypoints (ordered for stable numeric IDs)
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
  // Pathway waypoints (numbered)
  'wp_1', 'wp_2', 'wp_3', 'wp_4', 'wp_5', 'wp_6', 'wp_7', 'wp_8', 'wp_9', 'wp_10',
  'wp_11', 'wp_12', 'wp_13', 'wp_14', 'wp_15', 'wp_16', 'wp_17', 'wp_18', 'wp_19', 'wp_20',
  'wp_21', 'wp_22', 'wp_23', 'wp_24', 'wp_25', 'wp_26', 'wp_27', 'wp_28', 'wp_29', 'wp_30',
  'wp_31', 'wp_32', 'wp_33', 'wp_34', 'wp_35', 'wp_36', 'wp_37', 'wp_38', 'wp_39', 'wp_40',
  'wp_41', 'wp_42', 'wp_43', 'wp_44', 'wp_45', 'wp_46', 'wp_47', 'wp_48', 'wp_49', 'wp_50',
  'wp_51', 'wp_52', 'wp_53', 'wp_54', 'wp_55', 'wp_56', 'wp_57', 'wp_58', 'wp_59', 'wp_60',
  'wp_61', 'wp_62', 'wp_63', 'wp_64', 'wp_65', 'wp_66', 'wp_67', 'wp_68', 'wp_69', 'wp_70',
  'wp_71', 'wp_72', 'wp_73', 'wp_74', 'wp_75', 'wp_76',
];
