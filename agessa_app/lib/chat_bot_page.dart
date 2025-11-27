import 'package:flutter/material.dart';
import 'services/chatbot_service.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> with SingleTickerProviderStateMixin {
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _lightBlue = Color(0xFFE3F2FD);
  static const Color _accentBlue = Color(0xFF1976D2);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _addInitialMessage();
  }

  void _addInitialMessage() {
    setState(() {
      _messages.add(
        _Message(
          fromUser: false,
          text:'Merhaba!Ben Agessa Asistan.Size nasıl yardımcı olabilirim?',
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;
    
    // Add user message
    setState(() {
      _messages.add(_Message(
        fromUser: true, 
        text: text,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
      _isLoading = true;
    });
    
    // Close keyboard
    FocusScope.of(context).unfocus();
    
    // Trigger animation
    _animationController.forward().then((_) => _animationController.reverse());
    
    // Process the message
    _processMessage(text);
  }
  
  void _processMessage(String text) async {
    try {
      final response = await _chatbotService.getResponse(text);
      
      if (!mounted) return;
      
      setState(() {
        _messages.add(_Message(
          fromUser: false,
          text: response,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      
      // Scroll to bottom after adding message
      _scrollToBottom();
      
    } catch (e) {
      print('Error sending message: $e');
      if (!mounted) return;
      
      setState(() {
        _messages.add(_Message(
          fromUser: false,
          text: 'Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.',
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Agessa Asistan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return _ChatBubble(
                  message: m,
                  isFirst: index == 0 || _messages[index - 1].fromUser != m.fromUser,
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Mesajınızı yazın...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Material(
                              color: _primaryBlue,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  if (_controller.text.trim().isNotEmpty) {
                                    _send();
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.send, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _send(),
                        maxLines: 5,
                        minLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final bool fromUser;
  final String text;
  final DateTime timestamp;
  
  _Message({
    required this.fromUser,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class _ChatBubble extends StatelessWidget {
  final _Message message;
  final bool isFirst;
  
  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _lightBlue = Color(0xFFE3F2FD);
  
  const _ChatBubble({
    required this.message,
    this.isFirst = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;
    final bg = isUser ? _primaryBlue : _lightBlue;
    final textColor = isUser ? Colors.white : Colors.black87;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (isFirst) _buildHeader(isUser, message.timestamp),
          const SizedBox(height: 4),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isUser, DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isUser ? Colors.grey[300] : _primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUser ? Icons.person : Icons.smart_toy,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isUser ? 'Siz' : 'Agessa Asistan',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
