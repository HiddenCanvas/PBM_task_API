import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left status/decoration bar
              Container(
                width: 6,
                color: const Color(0xFF2D5A27),
              ),
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D5A27),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currencyFormatter.format(product.price),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D5A27),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.createdAt != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ditambahkan pada ${product.createdAt}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
