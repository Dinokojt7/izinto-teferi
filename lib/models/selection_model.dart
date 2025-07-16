class SelectionModel {
  int? id;
  String? name;
  // Add a boolean field to track selection status
  bool isSelected;

  SelectionModel({
    this.id,
    this.name,
    // Initialize isSelected to false by default
    this.isSelected = false,
    // Other properties...
  });
}
