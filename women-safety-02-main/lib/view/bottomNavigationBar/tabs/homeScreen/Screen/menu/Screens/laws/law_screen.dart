import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class LawScreen extends StatefulWidget {
  const LawScreen({super.key});

  @override
  State<LawScreen> createState() => _LawScreenState();
}

class _LawScreenState extends State<LawScreen> with TickerProviderStateMixin {
  final Map<String, Map<String, dynamic>> lawMap = {
    "Women Protection Laws": {
      "description":
          "Protection of Women (Criminal Laws Amendment) Act, 2006 was enacted to reform the harsh provisions of the Hudood Ordinances in Pakistan. Historically, Pakistan's legal framework included draconian measures such as whipping, amputation, and stoning which were intended to enforce moral conduct under Islamic law, but these measures often left women vulnerable in cases of sexual violence. The 2006 Act shifted the legal approach by treating rape as a criminal offense under the Pakistan Penal Code, easing the evidentiary burden on victims and eliminating the requirement for four eyewitnesses.",
      "category": "Protection",
      "icon": Icons.shield_outlined,
      "isBookmarked": false,
    },
    "Legal Rights and Protection": {
      "description":
          "Legal rights and protection for women in Pakistan have evolved through constitutional guarantees, judicial interpretations, and legislative reforms. The 1973 Constitution ensures equality before the law and prohibits discrimination on the basis of sex, while subsequent statutes such as the Protection Against Harassment of Women in the Workplace Act and the Prevention of Anti-Women Practices Act aim to address issues ranging from domestic abuse to inheritance disputes.",
      "category": "Rights",
      "icon": Icons.gavel_outlined,
      "isBookmarked": false,
    },
    "Criminal Laws": {
      "description":
          "Criminal laws in Pakistan have undergone significant transformation, especially regarding offenses that affect women. The historical influence of colonial-era statutes and the strict Hudood Ordinances resulted in harsh punishments for crimes like rape and adultery, often disadvantaging women. Reforms such as the 2006 Women Protection Law and later amendments reclassified these offenses under the Pakistan Penal Code, lowering the evidentiary threshold and establishing fixed minimum sentences—for example, a minimum of ten years' imprisonment for rape.",
      "category": "Criminal",
      "icon": Icons.balance_outlined,
      "isBookmarked": false,
    },
    "Support & Reporting Mechanism": {
      "description":
          "Support and reporting mechanisms are crucial in translating legal protections into real-world safety for women. In Pakistan, dedicated helplines, specialized police units, and fast-track courts have been established to enable confidential reporting of gender-based violence. These systems offer immediate assistance, including referrals for medical and psychological care, and work in tandem with non-governmental organizations to provide comprehensive support.",
      "category": "Support",
      "icon": Icons.people_outline,
      "isBookmarked": false,
    },
    "Legal Aid Service": {
      "description":
          "Legal aid services in Pakistan are essential for ensuring that marginalized women have access to justice despite the high costs and complexities of legal proceedings. Historically, the inaccessibility of legal representation meant that many women were unable to assert their rights. Government initiatives and non-governmental organizations have since established legal aid programs that provide pro-bono counsel and assistance with filing cases related to domestic violence, harassment, inheritance disputes, and more.",
      "category": "Aid",
      "icon": Icons.support_agent_outlined,
      "isBookmarked": false,
    },
    "Domestic Violence": {
      "description":
          "Domestic violence remains a pervasive issue in Pakistan, affecting women across diverse communities. Despite the existence of laws that provide for restraining orders, shelters, and rehabilitation services, many women continue to suffer abuse within their homes. The legal framework prescribes punitive measures for offenders, including imprisonment and fines, but enforcement is inconsistent due to socio-cultural barriers, limited resources, and a general reluctance to report abuse.",
      "category": "Protection",
      "icon": Icons.home_outlined,
      "isBookmarked": false,
    },
    "Awareness & Education": {
      "description":
          "Awareness and education are key drivers in the fight for gender equality in Pakistan. Over recent years, numerous initiatives have focused on educating women about their legal rights and challenging deeply entrenched patriarchal norms. Public awareness campaigns, legal literacy workshops, and media programs have significantly contributed to spreading knowledge about laws that protect women. Community outreach efforts engage local leaders, educators, and religious figures to promote gender sensitivity and inclusiveness.",
      "category": "Education",
      "icon": Icons.school_outlined,
      "isBookmarked": false,
    },
  };

  late AnimationController _headerAnimationController;
  late AnimationController _searchAnimationController;

  Set<String> expandedCards = Set<String>();
  String searchQuery = "";

  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocus = FocusNode();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimationController.forward();

    _searchFocus.addListener(() {
      setState(() {
        isSearching = _searchFocus.hasFocus;
        if (isSearching) {
          _searchAnimationController.forward();
        } else {
          _searchAnimationController.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _searchAnimationController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<MapEntry<String, Map<String, dynamic>>> get filteredLaws {
    return lawMap.entries.where((entry) {
      bool matchesSearch = searchQuery.isEmpty ||
          entry.key.toLowerCase().contains(searchQuery.toLowerCase()) ||
          entry.value["description"]
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF9F5FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _buildLawList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _headerAnimationController,
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20,
                      color: CustomColor.buttonColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  children: [
                    Text(
                      "Women's Legal Rights",
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3E5C),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Learn about laws protecting women",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Color(0xFF8F9BB3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      child: AnimatedBuilder(
        animation: _searchAnimationController,
        builder: (context, child) {
          return Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: isSearching
                      ? CustomColor.buttonColor.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSearching ? 15 : 8,
                  offset: Offset(0, 3),
                  spreadRadius: isSearching ? 2 : 0,
                ),
              ],
              border: isSearching
                  ? Border.all(
                      color: CustomColor.buttonColor.withOpacity(0.5),
                      width: 1.5)
                  : null,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Color(0xFF2E3E5C),
              ),
              decoration: InputDecoration(
                hintText: 'Search laws...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Color(0xFFA0A5BD),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color:
                      isSearching ? CustomColor.buttonColor : Color(0xFFA0A5BD),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Color(0xFFA0A5BD),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLawList() {
    if (filteredLaws.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 60,
              color: Color(0xFFBBC2DC),
            ),
            SizedBox(height: 16),
            Text(
              "No laws found",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8F9BB3),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Try a different search term",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFFA0A5BD),
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: BouncingScrollPhysics(),
        itemCount: filteredLaws.length,
        itemBuilder: (context, index) {
          final entry = filteredLaws[index];

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildLawCard(entry.key, entry.value),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLawCard(String title, Map<String, dynamic> lawData) {
    bool isExpanded = expandedCards.contains(title);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? CustomColor.buttonColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isExpanded ? 15 : 10,
            offset: Offset(0, 5),
            spreadRadius: isExpanded ? 1 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                if (expandedCards.contains(title)) {
                  expandedCards.remove(title);
                } else {
                  expandedCards.add(title);
                }
              });
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: _getCategoryColor(lawData["category"]),
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(lawData["category"])
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              lawData["icon"],
                              color: _getCategoryColor(lawData["category"]),
                              size: 22,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E3E5C),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              lawData["isBookmarked"]
                                  ? Icons.bookmark
                                  : Icons.bookmark_border_outlined,
                              color: lawData["isBookmarked"]
                                  ? CustomColor.buttonColor
                                  : Color(0xFF8F9BB3),
                            ),
                            onPressed: () {
                              setState(() {
                                lawMap[title]!["isBookmarked"] =
                                    !lawData["isBookmarked"];
                              });
                            },
                          ),
                        ],
                      ),

                      // Category chip
                      Container(
                        margin: EdgeInsets.only(top: 12, left: 4),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(lawData["category"])
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          lawData["category"],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _getCategoryColor(lawData["category"]),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      AnimatedCrossFade(
                        firstChild: Text(
                          lawData["description"].toString().substring(0, 100) +
                              "...",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Color(0xFF8F9BB3),
                            height: 1.5,
                          ),
                        ),
                        secondChild: Text(
                          lawData["description"],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Color(0xFF2E3E5C),
                            height: 1.6,
                          ),
                        ),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: Duration(milliseconds: 300),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isExpanded
                                  ? CustomColor.buttonColor
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isExpanded
                                    ? CustomColor.buttonColor
                                    : Color(0xFFE4E9F2),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: isExpanded
                                    ? Colors.white
                                    : Color(0xFF8F9BB3),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Protection":
        return Color(0xFFFF5630);
      case "Rights":
        return Color(0xFF00B8D9);
      case "Criminal":
        return Color(0xFF6554C0);
      case "Support":
        return Color(0xFF36B37E);
      case "Aid":
        return Color(0xFFFFAB00);
      case "Education":
        return Color(0xFF0065FF);
      default:
        return CustomColor.buttonColor;
    }
  }
}
