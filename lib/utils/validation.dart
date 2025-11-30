String? onRequiredValidation(String keyword, String? value) {
  if (value == null || value.trim().isEmpty) {
    return "$keyword is required";
  }

  return null;
}
