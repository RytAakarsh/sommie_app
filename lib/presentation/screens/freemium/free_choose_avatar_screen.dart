import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';


class FreeChooseAvatarScreen extends StatefulWidget {
  final VoidCallback onAvatarSelected;

  const FreeChooseAvatarScreen({
    super.key,
    required this.onAvatarSelected,
  });

  @override
  State<FreeChooseAvatarScreen> createState() => _FreeChooseAvatarScreenState();
}



class _FreeChooseAvatarScreenState extends State<FreeChooseAvatarScreen>
    with SingleTickerProviderStateMixin {
  String _selectedAvatar = '';
  String _selectedRole = '';
  bool _isSaving = false;
  String? _expandedAvatar;
  late AnimationController _animationController;

  final List<Map<String, String>> _avatars = [
    {
      'name': 'Lucía Herrera',
      'role_en': 'Regional Specialist',
      'role_pt': 'Especialista Regional',
      'img': 'assets/sommie_avatar/Avatar_Sommie_Lucia_Herrera.png',
    },
    {
      'name': 'Li Wei',
      'role_en': 'Precision Sommelier',
      'role_pt': 'Sommelier de Precisão',
      'img': 'assets/sommie_avatar/Avatar_Sommie_LiWei.png',
    },
    {
      'name': 'Karim Al-Nassir',
      'role_en': 'Global Pairing Expert',
      'role_pt': 'Especialista em Harmonização Global',
      'img': 'assets/sommie_avatar/Avatar_Sommie_karim_Al-Nassir.png',
    },
    {
      'name': 'Ama Kumasi',
      'role_en': 'Warm-Climate Enthusiast',
      'role_pt': 'Entusiasta de Clima Quente',
      'img': 'assets/sommie_avatar/Avatar_Sommie_Ama_Kumasi.png',
    },
    {
      'name': 'Miguel',
      'role_en': 'Expert in classic Wines',
      'role_pt': 'Especialista em Vinhos Clássicos',
      'img': 'assets/sommie_avatar/Avatares_sommie_Dom_Aurelius.png',
    },
    {
      'name': 'Amelie',
      'role_en': 'Trend Enthusiast',
      'role_pt': 'Entusiasta de Tendências',
      'img': 'assets/sommie_avatar/Avatares_Sommie_Amelie.png',
    },
  ];

  final Map<String, Map<String, String>> _avatarDetailsEn = {
    'Lucía Herrera': {
      'region': 'Maule Wine Region (Maule Valley Wine Route) and Casablanca, Chile.',
      'physical': 'Olive skin. Long, straight, shoulder-length black hair styled in an elegant half-updo. Almond-shaped hazel eyes. Soft jawline. Slender build.',
      'clothing': 'Slightly fitted white sommelier shirt. Premium dark burgundy vest. Straight black trousers and dress shoes. Waist-length sommelier apron. Silver pendant in the shape of a bunch of grapes.',
      'personality': 'Lucía exudes calm and knowledge. She is warm, patient, and slightly introspective. She has a subtle sense of humor and a very human touch.',
      'background': 'Lucía was born near Talca, into a family of grape farmers. She studied oenology and specialized in food and wine pairings. Her work led her to consulting for restaurants along the Wine Route.',
    },
    'Li Wei': {
      'region': 'Ningxia, China',
      'physical': 'Light, slightly matte skin. Straight black hair, styled to one side with impeccable, elegant flow. Serene eyes. Average height. Somewhat chiseled and refined facial features.',
      'clothing': 'White shirt, pearl gray vest, minimalist black bow tie/necktie.',
      'personality': 'Disciplined, observant, kind. Speaks sparingly, but every word carries weight. Maintains a calm and amiable demeanor.',
      'background': 'Li Wei was born in Guangzhou but moved with his family to the Ningxia region during his adolescence. There, he discovered the world of modern Chinese wine and became fascinated by the blend of European techniques, desert terroirs, and Chinese agricultural innovation.',
    },
    'Karim Al-Nassir': {
      'region': 'Bekaa Valley, Lebanon',
      'physical': 'Olive skin. Distinguished appearance. Expressive eyes. Tall and imposing presence.',
      'clothing': 'Petrol blue vest with a subtle texture. Dark trousers. Minimalist watch.',
      'personality': 'Charismatic, analytical, perfectionist. Speaks very clearly and inspires immediate confidence. Has a more serious style but rarely hides his smile.',
      'background': 'Karim grew up in Beirut in a family connected to gastronomy. At a young age, he was fascinated by the history of wine in Phoenicia. He studied international viticulture, worked in wineries in the Bekaa Valley, and then moved to Paris to perfect his skills in fine dining pairings.',
    },
    'Ama Kumasi': {
      'region': 'Ghana / South Africa',
      'physical': 'Deep ebony skin with warm highlights. Hair styled in fine braids gathered into a high bun. Golden brown eyes. High cheekbones and a large, kind, and confident smile. Tall and athletic build.',
      'clothing': 'White shirt, black vest with a very subtle geometric pattern in charcoal gray tones. Charcoal gray or muted gold sash. Small, circular earrings.',
      'personality': 'Extroverted. She has a contagious laugh and a very approachable way of communicating.',
      'background': 'Ama was born in Kumasi, in an area with a strong tradition of crafts and trade. She didn\'t come from a family connected to wine, but discovered her vocation while studying food chemistry. After receiving a scholarship to travel to South Africa, she fell in love with warm-climate wines.',
    },
    'Miguel': {
      'region': 'Classic Wine Regions',
      'physical': 'Distinguished appearance with refined features. Silver hair and a well-groomed beard.',
      'clothing': 'Traditional sommelier attire with a classic black vest and white shirt.',
      'personality': 'Knowledgeable, sophisticated, passionate about traditional winemaking. Patient and excellent at explaining complex concepts.',
      'background': 'An expert in classic wines from traditional regions, with decades of experience in viticulture and oenology. He has traveled extensively through Bordeaux, Tuscany, and Rioja.',
    },
    'Amelie': {
      'region': 'Modern Wine Regions',
      'physical': 'Energetic and vibrant appearance. Bright eyes and an expressive face. Modern stylish haircut.',
      'clothing': 'Modern and stylish clothing with a contemporary twist on traditional sommelier wear.',
      'personality': 'Trendy, innovative, always exploring new wine styles. Enthusiastic and passionate about sharing discoveries.',
      'background': 'Passionate about emerging wine regions and modern winemaking techniques. Always at the forefront of wine trends and constantly seeking out new producers and innovative approaches to viticulture.',
    },
  };

  final Map<String, Map<String, String>> _avatarDetailsPt = {
    'Lucía Herrera': {
      'region': 'Região Vinícola de Maule (Rota do Vinho do Vale do Maule) e Casablanca, Chile.',
      'physical': 'Pele morena. Cabelo preto liso, comprido até os ombros, estilizado em um elegante meio coque. Olhos castanhos amendoados. Linha da mandíbula suave. Estrutura esbelta.',
      'clothing': 'Camisa branca de sommelier levemente ajustada. Colete bordô escuro premium. Calça preta reta e sapatos sociais. Avental de sommelier na altura da cintura. Pingente de prata em forma de cacho de uvas.',
      'personality': 'Lucía exala calma e conhecimento. Ela é calorosa, paciente e ligeiramente introspectiva. Tem um senso de humor sutil e um toque muito humano.',
      'background': 'Lucía nasceu perto de Talca, em uma família de produtores de uva. Estudou enologia e especializou-se em harmonizações de comida e vinho. Seu trabalho a levou a consultorias para restaurantes ao longo da Rota do Vinho.',
    },
    'Li Wei': {
      'region': 'Ningxia, China',
      'physical': 'Pele clara, levemente fosca. Cabelo preto liso, penteado para o lado com fluxo impecável e elegante. Olhos serenos. Altura média. Traços faciais um tanto esculpidos e refinados.',
      'clothing': 'Camisa branca, colete cinza pérola, gravata borboleta/gravata preta minimalista.',
      'personality': 'Disciplinado, observador, gentil. Fala pouco, mas cada palavra tem peso. Mantém um comportamento calmo e amigável.',
      'background': 'Li Wei nasceu em Guangzhou, mas mudou-se com sua família para a região de Ningxia durante a adolescência. Lá, descobriu o mundo do vinho chinês moderno e fascinou-se pela mistura de técnicas europeias, terroirs desérticos e inovação agrícola chinesa.',
    },
    'Karim Al-Nassir': {
      'region': 'Vale do Bekaa, Líbano',
      'physical': 'Pele morena. Aparência distinta. Olhos expressivos. Presença alta e imponente.',
      'clothing': 'Colete azul-petróleo com textura sutil. Calças escuras. Relógio minimalista.',
      'personality': 'Carismático, analítico, perfeccionista. Fala muito claramente e inspira confiança imediata. Tem um estilo mais sério, mas raramente esconde o sorriso.',
      'background': 'Karim cresceu em Beirute em uma família ligada à gastronomia. Desde jovem, fascinou-se pela história do vinho na Fenícia. Estudou viticultura internacional, trabalhou em vinícolas no Vale do Bekaa e depois mudou-se para Paris para aperfeiçoar suas habilidades em harmonizações de alta gastronomia.',
    },
    'Ama Kumasi': {
      'region': 'Gana / África do Sul',
      'physical': 'Pele ébano profunda com reflexos quentes. Cabelo estilizado em tranças finas presas em um coque alto. Olhos castanho-dourados. Maçãs do rosto altas e um sorriso grande, gentil e confiante. Estrutura alta e atlética.',
      'clothing': 'Camisa branca, colete preto com padrão geométrico muito sutil em tons de cinza carvão. Faixa cinza carvão ou dourado suave. Brincos pequenos e circulares.',
      'personality': 'Extrovertida. Tem uma risada contagiante e uma forma muito acessível de se comunicar.',
      'background': 'Ama nasceu em Kumasi, em uma área com forte tradição de artesanato e comércio. Não veio de uma família ligada ao vinho, mas descobriu sua vocação enquanto estudava química de alimentos. Após receber uma bolsa para viajar à África do Sul, apaixonou-se por vinhos de clima quente.',
    },
    'Miguel': {
      'region': 'Regiões Vinícolas Clássicas',
      'physical': 'Aparência distinta com traços refinados. Cabelo prateado e barba bem cuidada.',
      'clothing': 'Traje tradicional de sommelier com colete preto clássico e camisa branca.',
      'personality': 'Conhecedor, sofisticado e apaixonado pela vinificação tradicional. Paciente e excelente em explicar conceitos complexos.',
      'background': 'Especialista em vinhos clássicos de regiões tradicionais, com décadas de experiência em viticultura e enologia. Viajou extensivamente por Bordeaux, Toscana e Rioja.',
    },
    'Amelie': {
      'region': 'Regiões Vinícolas Modernas',
      'physical': 'Aparência energética e vibrante. Olhos brilhantes e rosto expressivo. Corte de cabelo moderno e estiloso.',
      'clothing': 'Roupas modernas e estilosas com um toque contemporâneo no traje tradicional de sommelier.',
      'personality': 'Moderno, inovador, sempre explorando novos estilos de vinho. Entusiasta e apaixonada por compartilhar descobertas.',
      'background': 'Apaixonada por regiões vinícolas emergentes e técnicas modernas de vinificação. Sempre na vanguarda das tendências do vinho.',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentAvatar();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadCurrentAvatar() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentAvatar = authProvider.currentUser?.avatar ?? '';
    if (currentAvatar.isNotEmpty) {
      setState(() {
        _selectedAvatar = currentAvatar;
        final selected = _avatars.firstWhere(
          (a) => a['img'] == currentAvatar,
          orElse: () => {},
        );
        _selectedRole = selected['role_en'] ?? '';
      });
    }
  }

  Future<void> _saveAvatar() async {
    if (_selectedAvatar.isEmpty) return;

    setState(() => _isSaving = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.updateProfile({
      'avatar': _selectedAvatar,
      'role': _selectedRole,
    });

    setState(() => _isSaving = false);
    
    if (mounted) {
      widget.onAvatarSelected();
      Navigator.pop(context);
    }
  }

  void _toggleExpand(String avatarName) {
    setState(() {
      if (_expandedAvatar == avatarName) {
        _expandedAvatar = null;
      } else {
        _expandedAvatar = avatarName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          isPT ? 'Escolha seu Sommelier' : 'Choose Your Sommelier',
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade100,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people_alt,
                    color: Color(0xFF4B2B5F),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isPT
                        ? 'Escolha seu sommelier virtual preferido. Cada um tem sua própria personalidade e especialidade.'
                        : 'Choose your preferred virtual sommelier. Each has their own personality and specialty.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _avatars.length,
              itemBuilder: (context, index) {
                final avatar = _avatars[index];
                final isSelected = _selectedAvatar == avatar['img'];
                final isExpanded = _expandedAvatar == avatar['name'];
                final details = isPT 
                    ? _avatarDetailsPt[avatar['name']] 
                    : _avatarDetailsEn[avatar['name']];
                final role = isPT ? avatar['role_pt'] : avatar['role_en'];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? const Color(0xFF4B2B5F).withOpacity(0.15)
                            : Colors.grey.shade200,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF4B2B5F) 
                          : Colors.grey.shade100,
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar['img']!;
                          _selectedRole = avatar['role_en']!;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Avatar image with gradient border
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4B2B5F).withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Container(
                                      width: 65,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                colors: [Color(0xFF7f488b), Color(0xFF4B2B5F)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                      ),
                                      child: Padding(
                                        padding: isSelected ? const EdgeInsets.all(2) : EdgeInsets.zero,
                                        child: ClipOval(
                                          child: Image.asset(
                                            avatar['img']!,
                                            width: 65,
                                            height: 65,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: const Color(0xFF4B2B5F),
                                                child: Center(
                                                  child: Text(
                                                    avatar['name']![0],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        avatar['name']!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF4B2B5F),
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3E8FF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          role ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFF7f488b),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Selection indicator
                                if (isSelected)
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF7f488b), Color(0xFF4B2B5F)],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  )
                                else
                                  IconButton(
                                    icon: Icon(
                                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.grey.shade400,
                                    ),
                                    onPressed: () => _toggleExpand(avatar['name']!),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
                            ),
                          ),
                          // Expanded details section
                          if (isExpanded && details != null)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 0),
                                  const SizedBox(height: 16),
                                  _buildDetailCard(
                                    icon: Icons.location_on_outlined,
                                    title: isPT ? 'Região' : 'Region',
                                    content: details['region']!,
                                    isPT: isPT,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDetailCard(
                                    icon: Icons.face_outlined,
                                    title: isPT ? 'Descrição Física' : 'Physical Description',
                                    content: details['physical']!,
                                    isPT: isPT,
                                  ),
                                  if (details['clothing'] != null) ...[
                                    const SizedBox(height: 12),
                                    _buildDetailCard(
                                      icon: Icons.checkroom_outlined,
                                      title: isPT ? 'Vestuário' : 'Clothing',
                                      content: details['clothing']!,
                                      isPT: isPT,
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  _buildDetailCard(
                                    icon: Icons.psychology_outlined,
                                    title: isPT ? 'Personalidade' : 'Personality',
                                    content: details['personality']!,
                                    isPT: isPT,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDetailCard(
                                    icon: Icons.history_edu_outlined,
                                    title: isPT ? 'História' : 'Background',
                                    content: details['background']!,
                                    isPT: isPT,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4B2B5F),
                        side: const BorderSide(color: Color(0xFF4B2B5F), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isPT ? 'Cancelar' : 'Cancel',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedAvatar.isEmpty || _isSaving ? null : _saveAvatar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B2B5F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isPT ? 'Salvar Avatar' : 'Save Avatar',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
    required bool isPT,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF7f488b),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B2B5F),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
