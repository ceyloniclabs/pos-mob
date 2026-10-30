import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/models/country_model.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_customers/domain/usecases/update_customer_use_case.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';

class CustomerEditController extends GetxController {
  // 1. Dependencies and final fields
  final UpdateCustomerUseCase _updateCustomerUseCase;

  CustomerEditController({
    required this._updateCustomerUseCase,
  });

  /// The customer model instance being edited.
  late final Customer customer;

  // 2. Observable states
  /// Indicates if a saving/updating operation is in progress.
  final RxBool isLoading = false.obs;

  /// Currently selected country ID.
  final RxInt selectedCountryId = 0.obs;

  /// Currently selected customer type (local / foreigner).
  final RxString selectedCustomerType = ''.obs;

  /// Currently selected customer gender.
  final RxString selectedGender = ''.obs;

  /// Currently selected membership level.
  final RxString selectedMembershipLevel = MembershipLevel.bronze.value.obs;

  /// Observable file for the customer's profile photo.
  final Rx<File?> profilePhoto = Rx<File?>(null);

  /// Observable file for the customer's document.
  final Rx<File?> documentFile = Rx<File?>(null);

  /// List of available countries fetched from JSON.
  final RxList<CountryModel> countries = <CountryModel>[].obs;

  /// Indicates if the countries are currently loading.
  final RxBool isCountriesLoading = true.obs;

  // 3. Form and Text Controllers
  /// Form key to validate input fields.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Text controller for the customer's name.
  late final TextEditingController nameController;

  /// Text controller for the customer's phone number.
  late final TextEditingController phoneController;

  /// Text controller for the customer's email.
  late final TextEditingController emailController;

  /// Text controller for the customer's NIC.
  late final TextEditingController nicController;

  /// Text controller for the customer's passport ID.
  late final TextEditingController passportController;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      customer = Get.arguments as Customer;
    }

    _initializeData();
    fetchCountries();

    ever(selectedCustomerType, (type) {
      if (type == CustomerType.local.value) {
        final sriLanka = countries
            .firstWhereOrNull((c) => c.name.toLowerCase() == 'sri lanka');
        if (sriLanka != null) {
          selectedCountryId.value = sriLanka.id;
        }
      }
    });
  }

  void _initializeData() {
    // Initialize form controllers
    nameController = TextEditingController(text: customer.name);
    phoneController = TextEditingController(text: customer.phone);
    emailController = TextEditingController(text: customer.email);
    nicController = TextEditingController(text: customer.nic);
    passportController = TextEditingController(text: customer.passportId);

    // Set dropdown values
    selectedCountryId.value = customer.countryId;
    selectedCustomerType.value = customer.customerType.toLowerCase();
    selectedGender.value = customer.gender.toLowerCase();
    selectedMembershipLevel.value = customer.membershipLevel.toLowerCase();
  }

  /// Fetches a list of countries from local assets.
  Future<void> fetchCountries() async {
    try {
      isCountriesLoading.value = true;
      final String jsonString =
          await rootBundle.loadString('assets/json/countries.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      countries.value = jsonList
          .map((json) => CountryModel(
                id: json['id'],
                name: json['name'],
                isoCode: json['iso_code'],
              ))
          .toList();

      // Make sure selectedCountryId is set after countries are loaded
      selectedCountryId.value = customer.countryId;
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to load countries: $e');
    } finally {
      isCountriesLoading.value = false;
    }
  }

  /// Picks an image from the specified [source] (camera or gallery) and updates [profilePhoto].
  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        profilePhoto.value = File(image.path);
      }
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to pick image: $e');
    }
  }

  /// Picks a document file (PDF or Image) and updates [documentFile].
  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result.single.path != null) {
        documentFile.value = File(result.single.path!);
      }
    } catch (e) {
      ScaffoldMessageUtils.showError('Error picking document: $e');
    }
  }

  /// Submits the updated customer form data to the backend.
  Future<void> updateCustomer() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final updatedCustomer = Customer(
        id: customer.id,
        countryId: selectedCountryId.value,
        name: nameController.text,
        phone: phoneController.text,
        email: emailController.text,
        address: customer.address,
        profilePhoto: profilePhoto.value?.path ?? customer.profilePhoto,
        customerType: selectedCustomerType.value,
        gender: selectedGender.value,
        nic: selectedCustomerType.value == CustomerType.foreigner.value
            ? null
            : nicController.text,
        passportId: selectedCustomerType.value == CustomerType.local.value
            ? null
            : passportController.text,
        documentPhotoUrl: documentFile.value?.path ?? customer.documentPhotoUrl,
        membershipLevel: selectedMembershipLevel.value,
      );

      final result = await _updateCustomerUseCase.execute(updatedCustomer);
      log(result);
      Get.back(result: true);
      ScaffoldMessageUtils.showSuccess(result);
    } catch (e) {
      ScaffoldMessageUtils.showError(e.toString());
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    nicController.dispose();
    passportController.dispose();
    super.onClose();
  }
}
