import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:savings/DataProvider.dart';
import 'package:savings/constants/appColors.dart';
import 'package:savings/repository/textGenModel.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final textCont = TextEditingController();
  final scrollCont = ScrollController();
  bool responseLoaing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    textCont.dispose();
    scrollCont.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCont.hasClients) {
        scrollCont.animateTo(
          scrollCont.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        title: const Text(
          'Ask Anything',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontFamily: 'jaro',
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.blue),
            color: AppColors.white,
            surfaceTintColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    Provider.of<DataProvider>(context, listen: false)
                        .clearChats(); // From provider
                  });
                },
                child: const Text('Clear Chat'),
              ),
            ],
          )
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, _) {
          final chats = dataProvider.chats;
          scrollToBottom();

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 222, 234, 255),
                    Color.fromARGB(255, 253, 253, 253),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: chats.isEmpty
                        ? const Center(
                            child: Text(
                              'Start your conversation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollCont,
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              final chat = chats[index];

                              if (chat.parts[0].text.contains(
                                  "You are a financial assistant. Only reply to queries related to saving money, budgeting, or financial management. Keep your answers short and focused.")) {
                                return const SizedBox.shrink();
                              }

                              final isUser = chat.role == 'user';
                              final avatar = CircleAvatar(
                                backgroundColor:
                                    isUser ? Colors.blue : Colors.grey,
                                child: Icon(
                                  isUser ? Icons.person : Icons.smart_toy,
                                  color: Colors.white,
                                ),
                              );

                              final bubbleColor =
                                  isUser ? Colors.blue : Colors.white;
                              final textColor =
                                  isUser ? Colors.white : Colors.black87;
                              final alignment = isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft;

                              return Align(
                                alignment: alignment,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: isUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: isUser
                                        ? [
                                            Flexible(
                                              child: _chatBubble(
                                                  context,
                                                  chat.parts[0].text,
                                                  bubbleColor,
                                                  textColor),
                                            ),
                                            const SizedBox(width: 8),
                                            avatar,
                                          ]
                                        : [
                                            avatar,
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: _chatBubble(
                                                  context,
                                                  chat.parts[0].text,
                                                  bubbleColor,
                                                  textColor),
                                            ),
                                          ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // ✅ Input field — keyboard aware
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom +
                          8, // 👈 key
                      left: 12,
                      right: 12,
                      top: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: TextFormField(
                              controller: textCont,
                              scrollPadding: const EdgeInsets.only(bottom: 100),
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'Ask anything...',
                                hintStyle: const TextStyle(color: Colors.grey),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () async {
                            if (textCont.text.trim().isEmpty) return;

                            setState(() => responseLoaing = true);

                            final userQuestion =
                                textCont.text.trim().toLowerCase();
                            final dataProvider = Provider.of<DataProvider>(
                                context,
                                listen: false);
                            final transactionHistory =
                                dataProvider.transactionHistory ?? [];
                            final accountBalance = dataProvider.accountBalance;

                            String? localAnswer;
                            // Total deposit
                            if (userQuestion.contains('deposit') ||
                                userQuestion.contains('added') ||
                                userQuestion.contains('total deposit')) {
                              final totalDeposit = transactionHistory
                                  .where((tx) => tx.type == 'Added')
                                  .fold<int>(
                                      0, (sum, tx) => sum + (tx.amount ?? 0));
                              localAnswer =
                                  'Your total deposited amount is PKR $totalDeposit.';
                            }
                            // Total withdrawal
                            else if (userQuestion.contains('withdraw') ||
                                userQuestion.contains('withdrawal') ||
                                userQuestion.contains('total withdraw')) {
                              final totalWithdraw = transactionHistory
                                  .where((tx) => tx.type == 'Withdrawn')
                                  .fold<int>(
                                      0, (sum, tx) => sum + (tx.amount ?? 0));
                              localAnswer =
                                  'Your total withdrawn amount is PKR $totalWithdraw.';
                            }
                            // Account balance
                            else if (userQuestion.contains('balance') ||
                                userQuestion.contains('account balance') ||
                                userQuestion.contains('total balance')) {
                              localAnswer = accountBalance != null
                                  ? 'Your current account balance is PKR ${accountBalance.Balance}.'
                                  : 'Account balance data not available.';
                            }
                            // Last transaction
                            else if (userQuestion
                                    .contains('last transaction') ||
                                userQuestion.contains('recent transaction')) {
                              if (transactionHistory.isNotEmpty) {
                                final lastTx = transactionHistory.last;
                                localAnswer =
                                    'Your last transaction was ${lastTx.type} PKR ${lastTx.amount} for "${lastTx.title}" on ${lastTx.date}.';
                              } else {
                                localAnswer = 'No transactions found.';
                              }
                            }
                            // Average deposit
                            else if (userQuestion.contains('average deposit') ||
                                userQuestion.contains('deposit avg')) {
                              final deposits = transactionHistory
                                  .where((tx) => tx.type == 'Added')
                                  .toList();
                              final avg = deposits.isNotEmpty
                                  ? (deposits.fold<int>(
                                              0,
                                              (sum, tx) =>
                                                  sum + (tx.amount ?? 0)) /
                                          deposits.length)
                                      .toStringAsFixed(2)
                                  : '0';
                              localAnswer =
                                  'Your average deposit amount is PKR $avg.';
                            }
                            // Average withdrawal
                            else if (userQuestion
                                    .contains('average withdraw') ||
                                userQuestion.contains('withdraw avg')) {
                              final withdraws = transactionHistory
                                  .where((tx) => tx.type == 'Withdrawn')
                                  .toList();
                              final avg = withdraws.isNotEmpty
                                  ? (withdraws.fold<int>(
                                              0,
                                              (sum, tx) =>
                                                  sum + (tx.amount ?? 0)) /
                                          withdraws.length)
                                      .toStringAsFixed(2)
                                  : '0';
                              localAnswer =
                                  'Your average withdrawal amount is PKR $avg.';
                            }
                            // Monthly deposit/withdrawal
                            else if (userQuestion.contains('month')) {
                              // Try to extract month name
                              final months = [
                                'january',
                                'february',
                                'march',
                                'april',
                                'may',
                                'june',
                                'july',
                                'august',
                                'september',
                                'october',
                                'november',
                                'december'
                              ];
                              String? foundMonth;
                              for (final m in months) {
                                if (userQuestion.contains(m)) {
                                  foundMonth = m;
                                  break;
                                }
                              }
                              if (foundMonth != null) {
                                final monthNum = months.indexOf(foundMonth) + 1;
                                final yearMatch =
                                    RegExp(r'(\d{4})').firstMatch(userQuestion);
                                final year = yearMatch != null
                                    ? int.tryParse(yearMatch.group(0)!)
                                    : DateTime.now().year;
                                final monthTxs = transactionHistory.where((tx) {
                                  final txDate =
                                      DateTime.tryParse(tx.date ?? '') ??
                                          DateTime(2000);
                                  return txDate.month == monthNum &&
                                      txDate.year == year;
                                }).toList();
                                final deposit = monthTxs
                                    .where((tx) => tx.type == 'Added')
                                    .fold<int>(
                                        0, (sum, tx) => sum + (tx.amount ?? 0));
                                final withdraw = monthTxs
                                    .where((tx) => tx.type == 'Withdrawn')
                                    .fold<int>(
                                        0, (sum, tx) => sum + (tx.amount ?? 0));
                                localAnswer =
                                    'In $foundMonth $year, deposited: PKR $deposit, withdrawn: PKR $withdraw.';
                              }
                            }
                            // Specific date deposit/withdrawal
                            else if (userQuestion.contains('date')) {
                              final dateMatch = RegExp(r'(\d{4}-\d{2}-\d{2})')
                                  .firstMatch(userQuestion);
                              if (dateMatch != null) {
                                final dateStr = dateMatch.group(0)!;
                                final txs = transactionHistory.where((tx) {
                                  final txDate =
                                      DateTime.tryParse(tx.date ?? '')
                                          ?.toIso8601String()
                                          .substring(0, 10);
                                  return txDate == dateStr;
                                }).toList();
                                final deposit = txs
                                    .where((tx) => tx.type == 'Added')
                                    .fold<int>(
                                        0, (sum, tx) => sum + (tx.amount ?? 0));
                                final withdraw = txs
                                    .where((tx) => tx.type == 'Withdrawn')
                                    .fold<int>(
                                        0, (sum, tx) => sum + (tx.amount ?? 0));
                                localAnswer =
                                    'On $dateStr, deposited: PKR $deposit, withdrawn: PKR $withdraw.';
                              }
                            }

                            if (localAnswer != null) {
                              // Show user's question in chat
                              final userChat = TextGenModel(
                                role: 'user',
                                parts: [TextPartModel(text: textCont.text)],
                              );
                              dataProvider.addChat(userChat);
                              // Show local answer in chat
                              final answerChat = TextGenModel(
                                role: 'assistant',
                                parts: [TextPartModel(text: localAnswer)],
                              );
                              dataProvider.addChat(answerChat);
                              textCont.clear();
                              FocusScope.of(context).unfocus();
                              setState(() => responseLoaing = false);
                              return;
                            }

                            // Otherwise, send to AI
                            final chat = TextGenModel(
                              role: 'user',
                              parts: [TextPartModel(text: textCont.text)],
                            );

                            textCont.clear();
                            FocusScope.of(context).unfocus();

                            await dataProvider.sendChat(context, chat);

                            setState(() => responseLoaing = false);
                          },
                          child: responseLoaing
                              ? const SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: CircularProgressIndicator(),
                                )
                              : Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 21, 138, 234),
                                        Color.fromARGB(255, 70, 179, 230),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.send,
                                      color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chatBubble(BuildContext context, String text, Color bg, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bg.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: MarkdownBody(
          data: text,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: TextStyle(fontSize: 16, color: color),
          ),
        ),
      ),
    );
  }
}
