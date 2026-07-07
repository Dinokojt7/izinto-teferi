/// Fixed weight-tier catalog for the "pay by the bag" laundry flow. Standard
/// wash & fold moves from per-item pricing to these 3 flat tiers; specialty
/// items (duvets, sneakers, leather, etc.) stay per-item, see AddonItem below.
class BagTier {
  final String id;
  final String title;
  final int weightKg;
  final String loads;
  final int price;
  final String image;
  final bool popular;

  const BagTier({
    required this.id,
    required this.title,
    required this.weightKg,
    required this.loads,
    required this.price,
    required this.image,
    this.popular = false,
  });
}

const List<BagTier> kBagTiers = [
  BagTier(
    id: 'bag_9',
    title: 'Small bag',
    weightKg: 9,
    loads: 'about 2 loads',
    price: 149,
    image: 'assets/image/9-Kg-1.png',
  ),
  BagTier(
    id: 'bag_19',
    title: 'Medium bag',
    weightKg: 19,
    loads: 'about 4 loads',
    price: 249,
    image: 'assets/image/19-Kg-1.png',
    popular: true,
  ),
  BagTier(
    id: 'bag_48',
    title: 'Large bag',
    weightKg: 48,
    loads: 'about 10 loads',
    price: 549,
    image: 'assets/image/48-Kg-1.png',
  ),
];

const List<String> kWashTypes = ['Wash & Fold', 'Wash & Iron', 'Dry Clean'];

/// Specialty items that can't be bagged by weight — priced and billed
/// per-item on top of the selected bag tier.
class AddonItem {
  final int id;
  final String name;
  final int price;

  const AddonItem({required this.id, required this.name, required this.price});
}

const List<AddonItem> kLaundryAddons = [
  AddonItem(id: 90101, name: 'Duvet / Comforter', price: 120),
  AddonItem(id: 90102, name: 'Detailed Sneaker Wash', price: 100),
  AddonItem(id: 90103, name: 'Leather Care', price: 90),
  AddonItem(id: 90104, name: 'Rug & Carpet Care', price: 135),
  AddonItem(id: 90105, name: 'Curtains', price: 72),
];
