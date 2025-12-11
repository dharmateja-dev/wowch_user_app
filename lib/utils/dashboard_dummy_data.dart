import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';

/// Global dummy data for dashboard UI
/// This file contains dummy data matching the design image for categories, services, and featured services
class DashboardDummyData {
  /// Categories matching the image: Household, Cooking, Caretaker, Special Occasion Helper
  static List<CategoryData> getCategories() {
    return [
      CategoryData(
        id: 1,
        name: "Household",
        categoryImage: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400",
        description: "Professional household services",
        status: 1,
        isFeatured: 1,
        services: 15,
        color: "#95E1D3", // Light green
      ),
      CategoryData(
        id: 2,
        name: "Cooking",
        categoryImage: "https://images.unsplash.com/photo-1556911220-bff31c812dba?w=400",
        description: "Expert cooking services",
        status: 1,
        isFeatured: 1,
        services: 12,
        color: "#95E1D3", // Light green
      ),
      CategoryData(
        id: 3,
        name: "Caretaker",
        categoryImage: "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=400",
        description: "Professional caretaker services",
        status: 1,
        isFeatured: 1,
        services: 10,
        color: "#95E1D3", // Light green
      ),
      CategoryData(
        id: 4,
        name: "Special Occasion Helper",
        categoryImage: "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400",
        description: "Helpers for special occasions",
        status: 1,
        isFeatured: 1,
        services: 8,
        color: "#95E1D3", // Light green
      ),
    ];
  }

  /// Featured services matching the image: Housekeepers with ₹600, 30 min, Abdul Kader, 4.8 rating
  static List<ServiceData> getFeaturedServices() {
    return [
      ServiceData(
        id: 1,
        name: "Housekeepers",
        categoryId: 1,
        categoryName: "Household",
        providerId: 1,
        providerName: "Abdul Kader",
        providerImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        price: 600.0,
        discount: 0.0,
        duration: "30 min",
        description: "Professional housekeeping services",
        status: 1,
        isFeatured: 1,
        totalRating: 4.8,
        totalReview: 120,
        type: "fixed",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400",
        ],
        isFavourite: 0,
      ),
      ServiceData(
        id: 2,
        name: "Housekeepers",
        categoryId: 1,
        categoryName: "Household",
        providerId: 1,
        providerName: "Abdul Kader",
        providerImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        price: 600.0,
        discount: 0.0,
        duration: "30 min",
        description: "Professional housekeeping services",
        status: 1,
        isFeatured: 1,
        totalRating: 4.8,
        totalReview: 120,
        type: "fixed",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400",
        ],
        isFavourite: 0,
      ),
      ServiceData(
        id: 3,
        name: "Housekeepers",
        categoryId: 1,
        categoryName: "Household",
        providerId: 1,
        providerName: "Abdul Kader",
        providerImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        price: 600.0,
        discount: 0.0,
        duration: "30 min",
        description: "Professional housekeeping services",
        status: 1,
        isFeatured: 1,
        totalRating: 4.8,
        totalReview: 120,
        type: "fixed",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400",
        ],
        isFavourite: 0,
      ),
    ];
  }

  /// Services for the grid view (2 columns) - matching the image
  static List<ServiceData> getServices() {
    return [
      ServiceData(
        id: 4,
        name: "Housekeepers",
        categoryId: 1,
        categoryName: "Household",
        providerId: 1,
        providerName: "Abdul Kader",
        providerImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        price: 600.0,
        discount: 0.0,
        duration: "30 min",
        description: "Professional housekeeping services",
        status: 1,
        isFeatured: 0,
        totalRating: 4.8,
        totalReview: 120,
        type: "fixed",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400",
        ],
        isFavourite: 0,
      ),
      ServiceData(
        id: 5,
        name: "Housekeepers",
        categoryId: 1,
        categoryName: "Household",
        providerId: 1,
        providerName: "Abdul Kader",
        providerImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        price: 600.0,
        discount: 0.0,
        duration: "30 min",
        description: "Professional housekeeping services",
        status: 1,
        isFeatured: 0,
        totalRating: 4.8,
        totalReview: 120,
        type: "fixed",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400",
        ],
        isFavourite: 0,
      ),
      ServiceData(
        id: 6,
        name: "Housekeepers",
        categoryId: 1,
        categoryName: "Household",
        providerId: 1,
        providerName: "Abdul Kader",
        providerImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        price: 600.0,
        discount: 0.0,
        duration: "30 min",
        description: "Professional housekeeping services",
        status: 1,
        isFeatured: 0,
        totalRating: 4.8,
        totalReview: 120,
        type: "fixed",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400",
        ],
        isFavourite: 0,
      ),
      ServiceData(
        id: 7,
        name: "Housekeepers",
        categoryId: 1,
        categoryName: "Household",
        providerId: 1,
        providerName: "Abdul Kader",
        providerImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        price: 600.0,
        discount: 0.0,
        duration: "30 min",
        description: "Professional housekeeping services",
        status: 1,
        isFeatured: 0,
        totalRating: 4.8,
        totalReview: 120,
        type: "fixed",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400",
        ],
        isFavourite: 0,
      ),
      ServiceData(
        id: 8,
        name: "Housekeepers",
        categoryId: 1,
        categoryName: "Household",
        providerId: 1,
        providerName: "Abdul Kader",
        providerImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        price: 600.0,
        discount: 0.0,
        duration: "30 min",
        description: "Professional housekeeping services",
        status: 1,
        isFeatured: 0,
        totalRating: 4.8,
        totalReview: 120,
        type: "fixed",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400",
        ],
        isFavourite: 0,
      ),
      ServiceData(
        id: 9,
        name: "Housekeepers",
        categoryId: 1,
        categoryName: "Household",
        providerId: 1,
        providerName: "Abdul Kader",
        providerImage: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        price: 600.0,
        discount: 0.0,
        duration: "30 min",
        description: "Professional housekeeping services",
        status: 1,
        isFeatured: 0,
        totalRating: 4.8,
        totalReview: 120,
        type: "fixed",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400",
        ],
        isFavourite: 0,
      ),
    ];
  }
}



