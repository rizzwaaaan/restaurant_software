// windows/flutter_speech_recognition_windows_plugin.cs
using System;
using System.Speech.Recognition;
using Windows.UI.Xaml.Controls;

namespace FlutterSpeechRecognitionWindows
{
    public class FlutterSpeechRecognitionWindowsPlugin
    {
        private SpeechRecognitionEngine _recognizer;
        private FlutterMethodChannel _channel;

        public FlutterSpeechRecognitionWindowsPlugin(FlutterView view, FlutterMethodChannel channel)
        {
            _channel = channel;
            _recognizer = new SpeechRecognitionEngine(new System.Globalization.CultureInfo("en-US"));
            _recognizer.SetInputToDefaultAudioDevice();
            var choices = new Choices(new string[] { "check reservation", "make reservation", "show menu" });
            var grammar = new Grammar(new GrammarBuilder(choices));
            _recognizer.LoadGrammar(grammar);
            _recognizer.SpeechRecognized += (s, e) => _channel.InvokeMethod("onSpeechRecognized", e.Result.Text);
            _recognizer.SpeechRecognitionRejected += (s, e) => _channel.InvokeMethod("onSpeechError", "No speech recognized");
        }

        public bool Initialize()
        {
            try {
                return _recognizer != null;
            } catch {
                return false;
            }
        }

        public void StartListening()
        {
            _recognizer.RecognizeAsync(RecognizeMode.Multiple);
        }

        public void StopListening()
        {
            _recognizer.RecognizeAsyncStop();
        }
    }
}