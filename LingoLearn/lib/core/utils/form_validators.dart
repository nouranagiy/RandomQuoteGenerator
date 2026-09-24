String? Function(String?) requiredField(String message) =>
    (value) => (value == null || value.trim().isEmpty) ? message : null;
