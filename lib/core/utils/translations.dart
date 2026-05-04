import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/language_provider.dart';

class AppTranslations {
  static final Map<String, Map<String, String>> _strings = {
    'en': {
      // Cellar
      'my_cellar': 'My Cellar',
      'wines_count': 'wines',
      'search_wine': 'Search wine...',
      'all_countries': 'All countries',
      'all_types': 'All types',
      'sort_by': 'Sort by',
      'name_az': 'Name (A–Z)',
      'year_newest': 'Year (Newest)',
      'no_wines': 'No wines in your cellar',
      'add_first_wine': 'Add your first wine',
      'add_wine': 'Add Wine',
      'bottles': 'bottles',
      'bottle': 'bottle',
      'edit': 'Edit',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'save': 'Save',
      'confirm': 'Confirm',
      'back': 'Back',
      
      // Add Wine
      'add_wine_title': 'Add Wine to Cellar',
      'take_photo': 'Take Photo with Camera',
      'upload_gallery': 'Upload from Gallery',
      'photo_tip': 'Make sure the wine label is clear and well-lit',
      'processing': 'Processing...',
      
      // Preview Wine
      'preview_wine': 'Preview Wine Label',
      'preview_desc': 'Make sure the label is clear before scanning',
      'confirm_scan': 'Confirm & Scan Label',
      'retake_photo': 'Retake Photo',
      'ai_analyze': 'Our AI will analyze the label and extract wine details automatically',
      
      // Confirm Wine
      'confirm_wine': 'Confirm Wine Details',
      'confirm_desc': 'Review and edit the information',
      'basic_info': 'Basic Info',
      'wine_name': 'Wine Name',
      'origin': 'Origin',
      'country': 'Country',
      'region': 'Region',
      'wine_details': 'Wine Details',
      'wine_type': 'Wine Type',
      'grape_variety': 'Grape Variety',
      'year': 'Year',
      'alcohol': 'Alcohol %',
      'inventory': 'Inventory',
      'number_of_bottles': 'Number of Bottles',
      'notes': 'Notes',
      'optional': 'Optional',
      'add_to_cellar': 'Add to Cellar',
      'wine_added': 'Wine added to cellar!',
      'wine_updated': 'Wine updated!',
      'wine_deleted': 'Wine deleted!',
      'plan_limit_reached': 'Free plan limit reached (6 bottles). Upgrade to PRO!',
      'later': 'Later',
      'upgrade_to_pro': 'Upgrade to PRO',
      
      // Wine Types
      'red': 'Red',
      'white': 'White',
      'rose': 'Rosé',
      'sparkling': 'Sparkling',
    },
    'pt': {
      // Cellar
      'my_cellar': 'Minha Adega',
      'wines_count': 'vinhos',
      'search_wine': 'Buscar vinho...',
      'all_countries': 'Todos países',
      'all_types': 'Todos tipos',
      'sort_by': 'Ordenar por',
      'name_az': 'Nome (A–Z)',
      'year_newest': 'Ano (Mais recente)',
      'no_wines': 'Nenhum vinho na sua adega',
      'add_first_wine': 'Adicionar seu primeiro vinho',
      'add_wine': 'Adicionar Vinho',
      'bottles': 'garrafas',
      'bottle': 'garrafa',
      'edit': 'Editar',
      'delete': 'Excluir',
      'cancel': 'Cancelar',
      'save': 'Salvar',
      'confirm': 'Confirmar',
      'back': 'Voltar',
      
      // Add Wine
      'add_wine_title': 'Adicionar Vinho à Adega',
      'take_photo': 'Tirar Foto com Câmera',
      'upload_gallery': 'Enviar da Galeria',
      'photo_tip': 'Certifique-se de que o rótulo do vinho esteja claro e bem iluminado',
      'processing': 'Processando...',
      
      // Preview Wine
      'preview_wine': 'Pré-visualizar Rótulo',
      'preview_desc': 'Certifique-se de que o rótulo esteja claro antes de escanear',
      'confirm_scan': 'Confirmar e Escanear',
      'retake_photo': 'Tirar Nova Foto',
      'ai_analyze': 'Nossa IA analisará o rótulo e extrairá os detalhes do vinho automaticamente',
      
      // Confirm Wine
      'confirm_wine': 'Confirmar Detalhes do Vinho',
      'confirm_desc': 'Revise e edite as informações',
      'basic_info': 'Informações Básicas',
      'wine_name': 'Nome do Vinho',
      'origin': 'Origem',
      'country': 'País',
      'region': 'Região',
      'wine_details': 'Detalhes do Vinho',
      'wine_type': 'Tipo de Vinho',
      'grape_variety': 'Variedade da Uva',
      'year': 'Ano',
      'alcohol': 'Teor Alcoólico %',
      'inventory': 'Estoque',
      'number_of_bottles': 'Número de Garrafas',
      'notes': 'Observações',
      'optional': 'Opcional',
      'add_to_cellar': 'Adicionar à Adega',
      'wine_added': 'Vinho adicionado à adega!',
      'wine_updated': 'Vinho atualizado!',
      'wine_deleted': 'Vinho excluído!',
      'plan_limit_reached': 'Limite do plano gratuito atingido (6 garrafas). Assine o PRO!',
      'later': 'Depois',
      'upgrade_to_pro': 'Assinar PRO',
      
      // Wine Types
      'red': 'Tinto',
      'white': 'Branco',
      'rose': 'Rosé',
      'sparkling': 'Espumante',
    },
  };

  static String t(BuildContext context, String key) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = languageProvider.currentLanguage;
    return _strings[lang]?[key] ?? _strings['en']?[key] ?? key;
  }
}