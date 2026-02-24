// lib/utils/dummy_data.dart

class DummyData {
  static const List<String> salesHeaders = [
    "Category",
    "Product",
    "Quantity",
    "Amount",
  ];

  static const List<Map<String, dynamic>> salesData = [
    {
      "Category": "Beverages",
      "Product": "Pepsi 500ml",
      "Quantity": "10",
      "Amount": "1500",
    },
    {
      "Category": "Beverages",
      "Product": "Coke 500ml",
      "Quantity": "5",
      "Amount": "750",
    },
    {
      "Category": "Snacks",
      "Product": "Lays Classic",
      "Quantity": "20",
      "Amount": "1000",
    },
    {
      "Category": "Snacks",
      "Product": "Kurkure",
      "Quantity": "15",
      "Amount": "750",
    },
    {
      "Category": "Dairy",
      "Product": "Milk 1L",
      "Quantity": "8",
      "Amount": "1600",
    },
    {
      "Category": "Dairy",
      "Product": "Cheese 200g",
      "Quantity": "3",
      "Amount": "1200",
    },
    {
      "Category": "Dairy",
      "Product": "Yogurt",
      "Quantity": "10",
      "Amount": "500",
    },
    {
      "Category": "Bakery",
      "Product": "Bread",
      "Quantity": "12",
      "Amount": "600",
    },
    {
      "Category": "Bakery",
      "Product": "Cookies",
      "Quantity": "5",
      "Amount": "1000",
    },
  ];

  static const List<String> orderHeaders = [
    "Date",
    "Order ID",
    "Status",
    "Total",
  ];

  static const List<Map<String, dynamic>> orderData = [
    {
      "Date": "2024-02-01",
      "Order ID": "ORD-101",
      "Status": "Delivered",
      "Total": "500.00",
    },
    {
      "Date": "2024-02-02",
      "Order ID": "ORD-102",
      "Status": "Pending",
      "Total": "1200.50",
    },
    {
      "Date": "2024-02-02",
      "Order ID": "ORD-103",
      "Status": "Processing",
      "Total": "350.25",
    },
    {
      "Date": "2024-02-03",
      "Order ID": "ORD-104",
      "Status": "Delivered",
      "Total": "99.99",
    },
    {
      "Date": "2024-02-04",
      "Order ID": "ORD-105",
      "Status": "Cancelled",
      "Total": "250.00",
    },
    {
      "Date": "2024-02-05",
      "Order ID": "ORD-106",
      "Status": "Pending",
      "Total": "1500.00",
    },
  ];
}
