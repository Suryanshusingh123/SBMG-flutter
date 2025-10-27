import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myComplaint.
  ///
  /// In en, this message translates to:
  /// **'My Complaint'**
  String get myComplaint;

  /// No description provided for @schemes.
  ///
  /// In en, this message translates to:
  /// **'Schemes'**
  String get schemes;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @raiseComplaint.
  ///
  /// In en, this message translates to:
  /// **'Raise complaint'**
  String get raiseComplaint;

  /// No description provided for @callUsMessage.
  ///
  /// In en, this message translates to:
  /// **'Call us at 0141-2204880 for any complaint'**
  String get callUsMessage;

  /// No description provided for @featuredScheme.
  ///
  /// In en, this message translates to:
  /// **'Featured Scheme'**
  String get featuredScheme;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noSchemesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No schemes available'**
  String get noSchemesAvailable;

  /// No description provided for @surveyDetails.
  ///
  /// In en, this message translates to:
  /// **'Gp Master Data details'**
  String get surveyDetails;

  /// No description provided for @getContractorDetails.
  ///
  /// In en, this message translates to:
  /// **'Get your contractor details'**
  String get getContractorDetails;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get events;

  /// No description provided for @eventsPlural.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsPlural;

  /// No description provided for @noEventsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No events available'**
  String get noEventsAvailable;

  /// No description provided for @locationServicesRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Services Required'**
  String get locationServicesRequired;

  /// No description provided for @locationServicesMessage.
  ///
  /// In en, this message translates to:
  /// **'This app needs location services to geotag your complaint images. Please enable location services in your device settings.'**
  String get locationServicesMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// No description provided for @locationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'This app needs location permission to geotag your complaint images. This helps us verify the location of your complaints.'**
  String get locationPermissionMessage;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी (Hindi)'**
  String get hindi;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @noBookmarkedSchemes.
  ///
  /// In en, this message translates to:
  /// **'No bookmarked schemes'**
  String get noBookmarkedSchemes;

  /// No description provided for @noBookmarkedEvents.
  ///
  /// In en, this message translates to:
  /// **'No bookmarked events'**
  String get noBookmarkedEvents;

  /// No description provided for @bookmarkSchemesToSeeHere.
  ///
  /// In en, this message translates to:
  /// **'Bookmark schemes to see them here'**
  String get bookmarkSchemesToSeeHere;

  /// No description provided for @bookmarkEventsToSeeHere.
  ///
  /// In en, this message translates to:
  /// **'Bookmark events to see them here'**
  String get bookmarkEventsToSeeHere;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @latestUpdate.
  ///
  /// In en, this message translates to:
  /// **'(latest update)'**
  String get latestUpdate;

  /// No description provided for @complaintResolved.
  ///
  /// In en, this message translates to:
  /// **'Complaint resolved'**
  String get complaintResolved;

  /// No description provided for @underProcess.
  ///
  /// In en, this message translates to:
  /// **'Under Process'**
  String get underProcess;

  /// No description provided for @waitingFromYourEnd.
  ///
  /// In en, this message translates to:
  /// **'Waiting from your end'**
  String get waitingFromYourEnd;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @notSatisfied.
  ///
  /// In en, this message translates to:
  /// **'Not satisfied'**
  String get notSatisfied;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark Completed'**
  String get markCompleted;

  /// No description provided for @seeResolution.
  ///
  /// In en, this message translates to:
  /// **'See resolution'**
  String get seeResolution;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @selectTypeOfComplaint.
  ///
  /// In en, this message translates to:
  /// **'Select Type of Complaint'**
  String get selectTypeOfComplaint;

  /// No description provided for @describeComplaint.
  ///
  /// In en, this message translates to:
  /// **'Describe complaint'**
  String get describeComplaint;

  /// No description provided for @inputText.
  ///
  /// In en, this message translates to:
  /// **'Input Text'**
  String get inputText;

  /// No description provided for @nextAddLocation.
  ///
  /// In en, this message translates to:
  /// **'Next: Add location'**
  String get nextAddLocation;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Select option'**
  String get selectOption;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @requestComplaint.
  ///
  /// In en, this message translates to:
  /// **'Request Complaint'**
  String get requestComplaint;

  /// No description provided for @toRequestComplaint.
  ///
  /// In en, this message translates to:
  /// **'To request a complaint,\nplease login'**
  String get toRequestComplaint;

  /// No description provided for @maximumImagesAllowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum 2 images allowed'**
  String get maximumImagesAllowed;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get errorPickingImage;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields and upload at least one image'**
  String get pleaseFillAllFields;

  /// No description provided for @noComplaintTypesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No complaint types available'**
  String get noComplaintTypesAvailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loadingComplaintTypes.
  ///
  /// In en, this message translates to:
  /// **'Loading complaint types...'**
  String get loadingComplaintTypes;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @gramPanchayat.
  ///
  /// In en, this message translates to:
  /// **'Gram Panchayat'**
  String get gramPanchayat;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @wardArea.
  ///
  /// In en, this message translates to:
  /// **'Ward/Area'**
  String get wardArea;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @selectBlock.
  ///
  /// In en, this message translates to:
  /// **'Select Block'**
  String get selectBlock;

  /// No description provided for @selectGramPanchayat.
  ///
  /// In en, this message translates to:
  /// **'Select Gram Panchayat'**
  String get selectGramPanchayat;

  /// No description provided for @enterVillage.
  ///
  /// In en, this message translates to:
  /// **'Enter Village'**
  String get enterVillage;

  /// No description provided for @enterWardArea.
  ///
  /// In en, this message translates to:
  /// **'Enter Ward/Area'**
  String get enterWardArea;

  /// No description provided for @submitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Submit Complaint'**
  String get submitComplaint;

  /// No description provided for @authenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication required. Please login.'**
  String get authenticationRequired;

  /// No description provided for @complaintSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Complaint submitted successfully!'**
  String get complaintSubmittedSuccessfully;

  /// No description provided for @failedToSubmitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit complaint'**
  String get failedToSubmitComplaint;

  /// No description provided for @myCollection.
  ///
  /// In en, this message translates to:
  /// **'My Collection'**
  String get myCollection;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @giveUsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Give us Feedback'**
  String get giveUsFeedback;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @loginAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Login as Admin'**
  String get loginAsAdmin;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon!'**
  String get comingSoon;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get enterYourName;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @profileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSavedSuccessfully;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @notificationsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see notifications here when they arrive'**
  String get notificationsWillAppearHere;

  /// No description provided for @allNotificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get allNotificationsCleared;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @validTill.
  ///
  /// In en, this message translates to:
  /// **'Valid till'**
  String get validTill;

  /// No description provided for @noSchemesAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'No Schemes Available'**
  String get noSchemesAvailableMessage;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new schemes'**
  String get checkBackLater;

  /// No description provided for @errorLoadingSchemes.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Schemes'**
  String get errorLoadingSchemes;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @eligibility.
  ///
  /// In en, this message translates to:
  /// **'Eligibility'**
  String get eligibility;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// No description provided for @noBenefitsListed.
  ///
  /// In en, this message translates to:
  /// **'No benefits listed'**
  String get noBenefitsListed;

  /// No description provided for @eligibilityCriteria.
  ///
  /// In en, this message translates to:
  /// **'Eligibility Criteria'**
  String get eligibilityCriteria;

  /// No description provided for @noEligibilityCriteriaListed.
  ///
  /// In en, this message translates to:
  /// **'No eligibility criteria listed'**
  String get noEligibilityCriteriaListed;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get enterMobileNumber;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to mobile number'**
  String get enterOtpSentTo;

  /// No description provided for @weWillSendOtp.
  ///
  /// In en, this message translates to:
  /// **'We will send you a one-time password'**
  String get weWillSendOtp;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @enterMobileNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'00000 00000'**
  String get enterMobileNumberPlaceholder;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @enterOtpPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get enterOtpPlaceholder;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @otpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otpSentSuccessfully;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// No description provided for @pleaseEnterValidOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit OTP'**
  String get pleaseEnterValidOtp;

  /// No description provided for @pleaseEnterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter mobile number'**
  String get pleaseEnterMobileNumber;

  /// No description provided for @mobileNumberMustBe10Digits.
  ///
  /// In en, this message translates to:
  /// **'Mobile number must be 10 digits'**
  String get mobileNumberMustBe10Digits;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verifyAndLogin.
  ///
  /// In en, this message translates to:
  /// **'Verify & Login'**
  String get verifyAndLogin;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @knowYourAreasVendor.
  ///
  /// In en, this message translates to:
  /// **'Know your areas vendor'**
  String get knowYourAreasVendor;

  /// No description provided for @vendorDetails.
  ///
  /// In en, this message translates to:
  /// **'Vendor details'**
  String get vendorDetails;

  /// No description provided for @agencyInformation.
  ///
  /// In en, this message translates to:
  /// **'Agency Information'**
  String get agencyInformation;

  /// No description provided for @agencyName.
  ///
  /// In en, this message translates to:
  /// **'Agency Name'**
  String get agencyName;

  /// No description provided for @agencyPhone.
  ///
  /// In en, this message translates to:
  /// **'Agency Phone'**
  String get agencyPhone;

  /// No description provided for @agencyEmail.
  ///
  /// In en, this message translates to:
  /// **'Agency Email'**
  String get agencyEmail;

  /// No description provided for @agencyAddress.
  ///
  /// In en, this message translates to:
  /// **'Agency Address'**
  String get agencyAddress;

  /// No description provided for @contractorDetails.
  ///
  /// In en, this message translates to:
  /// **'Contractor Details'**
  String get contractorDetails;

  /// No description provided for @personName.
  ///
  /// In en, this message translates to:
  /// **'Person Name'**
  String get personName;

  /// No description provided for @personPhone.
  ///
  /// In en, this message translates to:
  /// **'Person Phone'**
  String get personPhone;

  /// No description provided for @contractInformation.
  ///
  /// In en, this message translates to:
  /// **'Contract Information'**
  String get contractInformation;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @getDetails.
  ///
  /// In en, this message translates to:
  /// **'Get details'**
  String get getDetails;

  /// No description provided for @pleaseSelectAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please select all fields'**
  String get pleaseSelectAllFields;

  /// No description provided for @failedToLoadDistricts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load districts'**
  String get failedToLoadDistricts;

  /// No description provided for @failedToLoadBlocks.
  ///
  /// In en, this message translates to:
  /// **'Failed to load blocks'**
  String get failedToLoadBlocks;

  /// No description provided for @failedToLoadVillages.
  ///
  /// In en, this message translates to:
  /// **'Failed to load villages'**
  String get failedToLoadVillages;

  /// No description provided for @failedToLoadContractorDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load contractor details'**
  String get failedToLoadContractorDetails;

  /// No description provided for @toViewYourComplaintStatus.
  ///
  /// In en, this message translates to:
  /// **'To view your lodged complaint status,\nplease login'**
  String get toViewYourComplaintStatus;

  /// No description provided for @noImagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No images available'**
  String get noImagesAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
