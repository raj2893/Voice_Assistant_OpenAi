import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/feature_box.dart';
import 'package:voice_assistant/openai_service.dart';
import 'package:voice_assistant/pallete.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  String lastWords = '';
  final flutterTts = FlutterTts();
  final OpenAiService openAiService = OpenAiService();
  String? generatedContent;
  String? generatedImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    setState(() {});
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> _startListening() async {
    await speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> _stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JARVIS Jr.'),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          //virtual assistant picture
          Roulette(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/jarvis.webp'),
                    ),
                  ),
                )
              ],
            ),
          ),
          Visibility(
            visible: generatedImageUrl == null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                top: 30,
              ),
              decoration: BoxDecoration(
                  color: generatedContent == null
                      ? Color.fromARGB(255, 244, 253, 250)
                      : Color.fromARGB(255, 255, 245, 245),
                  border: Border.all(
                    color: Pallete.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(25)
                      .copyWith(bottomLeft: Radius.zero)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  generatedContent == null
                      ? 'Hey! I am JARVIS Jr.\nYou can ask me anything you want!'
                      : generatedContent!,
                  style: GoogleFonts.ubuntu(
                    color: Pallete.mainFontColor,
                    fontSize: generatedContent == null ? 20 : 16,
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text(
                      'Your Response is loading...',
                      style: TextStyle(fontSize: 10),
                    )
                  ]),
            )
          else if (generatedImageUrl != null)
            Padding(
                padding: EdgeInsets.all(15),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImageUrl!))),
          // Visibility(
          //   visible: generatedContent == null && generatedImageUrl == null,
          //   child: Container(
          //     padding: const EdgeInsets.all(10),
          //     margin: const EdgeInsets.only(top: 10, left: 10),
          //     alignment: Alignment.centerLeft,
          //     child: Text(
          //       'Here are few recommendations!',
          //       style: GoogleFonts.ubuntu(
          //           color: Pallete.mainFontColor,
          //           fontSize: 18,
          //           fontWeight: FontWeight.bold),
          //     ),
          //   ),
          // ),
          //Features List
          Visibility(
            visible: generatedContent == null && generatedImageUrl == null,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Image.asset('assets/images/OpenAI.png'),
                ),
                FeatureBox(
                  color: const Color.fromARGB(255, 176, 255, 217),
                  headerText: 'To get started',
                  descriptionText: 'Tap on the mic icon, and start saying...',
                )
                // FeatureBox(
                //   color: Pallete.firstSuggestionBoxColor,
                //   headerText: 'ChatGpt',
                //   descriptionText: 'A smarter way to get your work done',
                // ),
                // FeatureBox(
                //   color: Pallete.secondSuggestionBoxColor,
                //   headerText: 'Dall-E',
                //   descriptionText:
                //       'Get inspired and stay creative with your personal assistant powered by Dall-E',
                // ),
                // FeatureBox(
                //   color: Pallete.thirdSuggestionBoxColor,
                //   headerText: 'Smart Voice Assistant',
                //   descriptionText:
                //       'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                // ),
              ],
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await _startListening();
          } else if (speechToText.isListening) {
            setState(() {
              isLoading = true;
            });
            final speech = await openAiService.isArtPromptAPI(lastWords);
            setState(() {
              isLoading = false;
              if (speech.contains('https')) {
                generatedImageUrl = speech;
                generatedContent = null;
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
              }
            });
            await systemSpeak(speech);

            print(speech);

            await _stopListening();
          } else {
            initSpeechToText();
          }
        },
        child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
