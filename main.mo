import Text "mo:core/Text";
import Array "mo:core/Array";
import Runtime "mo:core/Runtime";
import Map "mo:core/Map";
import List "mo:core/List";
import Nat "mo:core/Nat";
import Order "mo:core/Order";
import Time "mo:core/Time";
import Principal "mo:core/Principal";
import MixinAuthorization "authorization/MixinAuthorization";
import AccessControl "authorization/access-control";

actor {
  var nextId = 1;
  let persistentOpps = Map.empty<Nat, Opportunity>();

  let accessControlState = AccessControl.initState();
  include MixinAuthorization(accessControlState);

  type Opportunity = {
    id : Nat;
    title : Text;
    company : Text;
    role : Text;
    eligibility : Text;
    deadline : Text;
    link : Text;
    source : Text;
    description : Text;
    tags : List.List<Text>;
    status : Text;
    createdAt : Int;
  };

  type OpportunityView = {
    id : Nat;
    title : Text;
    company : Text;
    role : Text;
    eligibility : Text;
    deadline : Text;
    link : Text;
    source : Text;
    description : Text;
    tags : [Text];
    status : Text;
    createdAt : Int;
  };

  type CreateOpportunityArgs = {
    title : Text;
    company : Text;
    role : Text;
    eligibility : Text;
    deadline : Text;
    link : Text;
    source : Text;
    description : Text;
    tags : [Text];
    status : Text;
  };

  func toView(opp : Opportunity) : OpportunityView {
    {
      id = opp.id;
      title = opp.title;
      company = opp.company;
      role = opp.role;
      eligibility = opp.eligibility;
      deadline = opp.deadline;
      link = opp.link;
      source = opp.source;
      description = opp.description;
      tags = opp.tags.toArray();
      status = opp.status;
      createdAt = opp.createdAt;
    };
  };

  func persistentToView(persistentOpps : Map.Map<Nat, Opportunity>) : [OpportunityView] {
    persistentOpps.values().toArray().map(toView);
  };

  module OpportunityView {
    public func compareByDeadline(a : OpportunityView, b : OpportunityView) : Order.Order {
      Text.compare(a.deadline, b.deadline);
    };
  };

  module TimeUtils {
    public func getCurrentTime() : Int {
      Time.now() / 1_000_000_000;
    };

    public func addDays(dateString : Text, days : Int) : Text {
      dateString;
    };
  };

  func filterOpps(predicate : (Opportunity) -> Bool) : [Opportunity] {
    persistentOpps.values().toArray().filter(predicate);
  };

  func filterComponent(predicate : (Opportunity) -> Bool) : [Opportunity] {
    persistentOpps.values().toArray().filter(predicate);
  };

  func filterPersistentAndConvert(predicate : (Opportunity) -> Bool) : [OpportunityView] {
    filterComponent(predicate).map(toView);
  };

  public shared ({ caller }) func initialize() : async () {
    if (persistentOpps.isEmpty()) {
      if (not AccessControl.isAdmin(accessControlState, caller)) {
        Runtime.trap("Unauthorized: Only admins can initialize the tracker");
      };
      let now = TimeUtils.getCurrentTime();
      let sampleOpportunities = [
        {
          title = "Software Engineer Intern";
          company = "Google";
          role = "Backend Developer";
          eligibility = "3rd year CS students";
          deadline = TimeUtils.addDays("2024-07-10", 30);
          link = "https://careers.google.com/jobs";
          source = "LinkedIn";
          description = "Gain experience in major backend projects. Join a dynamic team of talented engineers and network with industry experts. Work on real-world solutions impacting millions of users. Ideal for students passionate about technology and innovation.";
          tags = List.fromArray(["software", "backend", "internship", "tech"]);
          status = "open";
          createdAt = now;
        },
        {
          title = "Risk Analyst Intern at JPMorgan";
          company = "JPMorgan Chase & Co.";
          role = "Risk Analyst Intern";
          eligibility = "Final year finance students";
          deadline = TimeUtils.addDays("2024-08-30", 45);
          link = "https://careers.jpmorgan.com/jobs";
          source = "Email";
          description = "Work alongside experienced risk analysts. Analyze financial data for risk assessment. Gain insights into risk management strategies used by top financial institutions. Apply quantitative and analytical skills in a collaborative environment.";
          tags = List.fromArray(["Finance", "Risk", "Internship", "Analyst"]);
          status = "open";
          createdAt = now;
        },
        {
          title = "Marketing Intern";
          company = "Unilever";
          role = "Marketing Intern";
          eligibility = "All undergrads";
          deadline = TimeUtils.addDays("2024-06-15", 60);
          link = "https://careers.unilever.com/jobs";
          source = "WhatsApp";
          description = "Develop marketing campaigns for Unilever's product lines. Gain practical experience in digital marketing and brand strategy. Collaborate with marketing professionals to enhance promotional initiatives. Suitable for students interested in business and creativity.";
          tags = List.fromArray(["marketing", "brand", "internship", "digital"]);
          status = "open";
          createdAt = now;
        },
        {
          title = "Investment Banking Associate";
          company = "Goldman Sachs";
          role = "Investment Banking Associate";
          eligibility = "MBA Grads";
          deadline = TimeUtils.addDays("2024-12-01", 180);
          link = "https://gs.com/careers";
          source = "LinkedIn";
          description = "Participate in high-stakes investment banking projects. Gain exposure to financial modeling and market analysis. Learn from leading professionals with opportunities for advanced training. Ideal for MBA graduates aiming for a finance career.";
          tags = List.fromArray(["Finance", "Investment", "Finance", "MBA"]);
          status = "open";
          createdAt = now;
        },
        {
          title = "Research Assistant";
          company = "Stanford University";
          role = "Research Assistant";
          eligibility = "PhD Candidates";
          deadline = TimeUtils.addDays("2025-01-15", 200);
          link = "https://stanford.edu/careers";
          source = "Email";
          description = "Contribute to cutting-edge academic research. Collaborate with esteemed faculty and researchers. Enhance your research methodologies and analytical skills. Suitable for students passionate about academic pursuits.";
          tags = List.fromArray(["Research", "Assistant", "Academic", "Faculty"]);
          status = "open";
          createdAt = now;
        },
        {
          title = "Creative Design Specialist";
          company = "Nike";
          role = "Creative Design Specialist";
          eligibility = "Art Majors";
          deadline = TimeUtils.addDays("2024-09-30", 45);
          link = "https://nike.com/careers";
          source = "Email";
          description = "Lead creative projects from concept to implementation. Develop graphics and visual assets for Nike's campaigns. Collaborate with cross-functional teams to execute branding strategies. Ideal for individuals with a passion for art and design.";
          tags = List.fromArray(["Design", "Creative", "Art", "Graphic"]);
          status = "open";
          createdAt = now;
        },
      ];

      for (sampleOrganization in sampleOpportunities.values()) {
        let opportunity : Opportunity = {
          id = nextId;
          title = sampleOrganization.title;
          company = sampleOrganization.company;
          role = sampleOrganization.role;
          eligibility = sampleOrganization.eligibility;
          deadline = sampleOrganization.deadline;
          link = sampleOrganization.link;
          source = sampleOrganization.source;
          description = sampleOrganization.description;
          tags = sampleOrganization.tags;
          status = sampleOrganization.status;
          createdAt = sampleOrganization.createdAt;
        };
        persistentOpps.add(nextId, opportunity);
        nextId += 1;
      };
    };
  };

  public query ({ caller }) func getAllOpportunities() : async [OpportunityView] {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized: Only authorized users can access opportunities");
    };
    persistentToView(persistentOpps);
  };

  public query ({ caller }) func filterByStatus(status : Text) : async [OpportunityView] {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized: Only authorized users can filter opportunities");
    };
    filterPersistentAndConvert(func(o) { o.status == status });
  };

  public query ({ caller }) func searchByKeyword(keyword : Text) : async [OpportunityView] {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized: Only authorized users can search opportunities");
    };
    filterPersistentAndConvert(
      func(o) {
        o.title.toLower().contains(#text(keyword.toLower())) or
        o.company.toLower().contains(#text(keyword.toLower())) or
        o.role.toLower().contains(#text(keyword.toLower())) or
        o.description.toLower().contains(#text(keyword.toLower()));
      }
    );
  };

  public query ({ caller }) func getUpcomingDeadlines() : async [OpportunityView] {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized: Only authorized users can view upcoming deadlines");
    };
    persistentToView(persistentOpps).sort(OpportunityView.compareByDeadline);
  };

  public query ({ caller }) func getOpportunityById(id : Nat) : async OpportunityView {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized: Only authorized users can view opportunities");
    };
    switch (persistentOpps.get(id)) {
      case (?opp) { toView(opp) };
      case (null) { Runtime.trap("Opportunity not found") };
    };
  };

  public shared ({ caller }) func createOpportunity(args : CreateOpportunityArgs) : async Nat {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized: Only authorized users can add new opportunities");
    };
    let newOpp : Opportunity = {
      id = nextId;
      title = args.title;
      company = args.company;
      role = args.role;
      eligibility = args.eligibility;
      deadline = args.deadline;
      link = args.link;
      source = args.source;
      description = args.description;
      tags = List.fromArray(args.tags);
      status = args.status;
      createdAt = Time.now() / 1_000_000_000;
    };
    persistentOpps.add(nextId, newOpp);
    nextId += 1;
    nextId - 1;
  };

  public shared ({ caller }) func updateOpportunity(id : Nat, args : CreateOpportunityArgs) : async () {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized: Only authorized users can edit opportunities");
    };
    let existing = switch (persistentOpps.get(id)) {
      case (?opp) { opp };
      case (null) { Runtime.trap("Opportunity not found") };
    };
    let updatedOpp : Opportunity = {
      id;
      title = args.title;
      company = args.company;
      role = args.role;
      eligibility = args.eligibility;
      deadline = args.deadline;
      link = args.link;
      source = args.source;
      description = args.description;
      tags = List.fromArray(args.tags);
      status = args.status;
      createdAt = existing.createdAt;
    };
    persistentOpps.add(id, updatedOpp);
  };

  public shared ({ caller }) func deleteOpportunity(id : Nat) : async () {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized: Only authorized users can delete opportunities");
    };
    if (not persistentOpps.containsKey(id)) {
      Runtime.trap("Opportunity not found");
    };
    persistentOpps.remove(id);
  };
};
