import '../models/portfolio.dart';
import '../sources/portfolio_content.dart' as content;

/// Read-only site content. Today it serves the bundled constants; it is the
/// single place to switch to Supabase (anon key, read-only tables) later.
class PortfolioRepository {
  const PortfolioRepository();

  Profile get profile => content.profile;

  List<String> get aboutParagraphs => content.aboutParagraphs;
  List<String> get coreStack => content.coreStack;
  List<Service> get services => content.services;
  List<String> get practices => content.practices;

  List<Job> get jobs => content.jobs;
  List<Project> get projects => content.projects;
  List<SkillGroup> get skillGroups => content.skillGroups;
  List<Post> get posts => content.posts;

  String get projectsLead => content.projectsLead;
  String get writingLead => content.writingLead;
  String get contactLead => content.contactLead;

  List<InquiryType> get inquiryTypes => content.inquiryTypes;

  String get chatGreeting => content.chatGreeting;
  String get chatError => content.chatError;
  List<QuickPrompt> get chatQuickPrompts => content.chatQuickPrompts;
}
