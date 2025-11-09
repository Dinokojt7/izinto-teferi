// order_support_chat.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../../services/notification_service.dart';
import '../../../../models/user.dart';
import '../../utilities/colors.dart';
import 'controller/order_support_controller.dart';

class OrderSupportChat extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderSupportChat({Key? key, required this.order}) : super(key: key);

  @override
  _OrderSupportChatState createState() => _OrderSupportChatState();
}

class _OrderSupportChatState extends State<OrderSupportChat> {
  final TextEditingController _messageController = TextEditingController();
  late ScrollController _scrollController;
  late String _chatRoomId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _chatRoomId = 'order_${widget.order['orderId']}_support';

    // Mark messages as read when opening chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          Provider.of<OrderSupportController>(context, listen: false);
      controller.markMessagesAsRead(widget.order['orderId']);
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final controller =
        Provider.of<OrderSupportController>(context, listen: false);
    await controller.sendMessage(widget.order['orderId'], message);

    _messageController.clear();

    // Scroll to bottom
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final controller = Provider.of<OrderSupportController>(context);

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.97),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          // Custom App Bar
          _buildChatHeader(),

          // Chat Messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: controller.getMessagesStream(widget.order['orderId']),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading messages',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: LiveColors.accent,
                    ),
                  );
                }

                final messages = snapshot.data!.docs;
                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(Dimensions.width15),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageDoc = messages[index];
                    final messageData =
                        messageDoc.data() as Map<String, dynamic>;
                    return _buildMessageBubble(messageData, user);
                  },
                );
              },
            ),
          ),

          // Message Input
          _buildMessageInput(controller),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height15,
        ),
        child: Row(
          children: [
            // Back Button
            IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: Dimensions.width10),

            // Order Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Support',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 1.1,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Order #${widget.order['orderId']}',
                    style: TextStyle(
                      fontSize: Dimensions.font16 / 1.2,
                      color: Colors.grey.shade600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width10,
                vertical: Dimensions.height10 / 2,
              ),
              decoration: BoxDecoration(
                color: LiveColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: LiveColors.accent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _getStatusText(widget.order['status']),
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.3,
                  color: LiveColors.accent,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
      Map<String, dynamic> messageData, UserModel? user) {
    final isUserMessage = messageData['senderId'] == user?.uid;
    final message = messageData['message'] ?? '';
    final timestamp = messageData['timestamp'] as Timestamp?;
    final messageTime = timestamp != null
        ? DateFormat('HH:mm').format(timestamp.toDate())
        : '--:--';

    // Check if we need to show date separator
    final messageDate = timestamp != null ? timestamp.toDate() : DateTime.now();
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));

    String? dateSeparator;
    if (messageDate.year == today.year &&
        messageDate.month == today.month &&
        messageDate.day == today.day) {
      dateSeparator = 'Today';
    } else if (messageDate.year == yesterday.year &&
        messageDate.month == yesterday.month &&
        messageDate.day == yesterday.day) {
      dateSeparator = 'Yesterday';
    } else {
      dateSeparator = DateFormat('MMM dd, yyyy').format(messageDate);
    }

    // Check if we should show date separator for this message
    final shouldShowDate = dateSeparator != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date Separator
        if (shouldShowDate) ...[
          Container(
            margin: EdgeInsets.symmetric(vertical: Dimensions.height15),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height10 / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  dateSeparator!,
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.3,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
        ],

        // Message Bubble
        Align(
          alignment:
              isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: EdgeInsets.only(bottom: Dimensions.height10),
            child: Column(
              crossAxisAlignment: isUserMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Message Bubble
                Container(
                  padding: EdgeInsets.all(Dimensions.width15),
                  decoration: BoxDecoration(
                    color: isUserMessage
                        ? LiveColors.accent.withOpacity(0.9)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: isUserMessage
                          ? Radius.circular(16)
                          : Radius.circular(4),
                      bottomRight: isUserMessage
                          ? Radius.circular(4)
                          : Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: Dimensions.font16 / 1.1,
                      color: isUserMessage ? Colors.white : Colors.black87,
                      fontFamily: 'Poppins',
                      height: 1.4,
                    ),
                  ),
                ),

                // Time
                SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    messageTime,
                    style: TextStyle(
                      fontSize: Dimensions.font16 / 1.4,
                      color: Colors.grey.shade500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(OrderSupportController controller) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Message Input
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width15,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: Dimensions.height15 / 1.1),
                ),
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontFamily: 'Poppins',
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          // Send Button
          SizedBox(width: Dimensions.width10),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LiveColors.accent,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: controller.isLoading ? null : _sendMessage,
              padding: EdgeInsets.all(Dimensions.width10),
              constraints: BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: Dimensions.height20),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: Dimensions.font16,
              color: Colors.grey.shade600,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            'Start a conversation with our support team',
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.2,
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
      case 'processing':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
