// Copyright (c) 2026 ROKCT INTELLIGENCE (PTY) LTD
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, version 3.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

// Render harness for the shared review-strip kit (RokctAI/shared-workflows
// scripts/render/README.md, templates/render-harness/render_screen_test.dart).
//
// Screen: the polaris BORROWER HOME - PolarisHomeRouteView, the host route the
// app opens after sign-in, which hosts polaris_sdk's LoanScreen (the apply
// card, the loan status and the loan history). It is the same route the tour's
// `polaris` fragment walks, so the review shows what the tour shows.
//
// The route is installed by the composer into lib/presentation/routes/ and
// initialises PolarisSDK itself in demo sessions, so the harness pumps the
// real route rather than reconstructing its config.
//
// Everything below the "proven mechanism" banner is the kit's, unchanged.
//
// This runs against the COMPOSED app - `lib/` and the SDK caches only exist
// after `.rokct` compose, so the imports below resolve on a composed tree only.
// The render gate composes before it runs this (universal-guided-tour.yml).
//
// Data: a demo session is activated and the SDKs register their REAL Http
// repositories; base_sdk's DemoGatewayInterceptor answers every platform cmd
// from the SDKs' own `<cmd>.json` fixtures (polaris: assets/demo/polaris).
//
// Run:  flutter test test/render/render_screen_test.dart
//       RENDER_SUFFIX=_draft flutter test test/render/render_screen_test.dart

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
// The offline seam google_fonts documents for tests: `httpClient` is
// @visibleForTesting, so the harness can serve the faces committed beside
// this file instead of reaching fonts.gstatic.com.
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as google_fonts_base;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:auth_sdk/auth_sdk.dart' show AuthSdkDependencies;
// ignore: implementation_imports
import 'package:auth_sdk/src/common/services/session_profile.dart'
    show sessionProfileOf;
import 'package:base_sdk/base_sdk.dart'
    show BaseSdkDependencies, DemoSession, LocalStorage;
// Deep imports into base_sdk's src/ are expected in a harness (the kit's
// template says so): the auth facade is not on the base_sdk barrel.
import 'package:base_sdk/src/domain/interface/auth.dart'
    show AuthRepositoryFacade;
// ApiResult's `when` is an extension declared in its freezed part.
import 'package:base_sdk/src/handlers/api_result.dart';
import 'package:base_sdk/src/presentation/theme/app_style.dart' show AppStyle;
import 'package:users_sdk/users_sdk.dart' show UsersSdkDependencies;

// The host route the app opens after sign-in (composed into lib/).
import 'package:polaris/presentation/routes/polaris_route_pages.dart'
    show PolarisHomeRouteView;

// ---------------------------------------------------------------------------
// Render settings - phone size the reviews are judged at.
// ---------------------------------------------------------------------------

/// Logical width of the frame (iPhone-class phone).
const double kLogicalWidth = 390;

/// Device pixel ratio the PNG is captured at (3 = @3x).
const double kDevicePixelRatio = 3.0;

/// Tall probe viewport for the first pass. Must exceed the tallest screen.
const double kProbeHeight = 2600;

/// Slack below the last element in the final frame, in logical pixels.
const double kBottomPadding = 20;

/// Elements anchored to the VIEWPORT, not to the end of the content. The
/// polaris home has no floating nav, so nothing is viewport-anchored today.
const Set<String> kViewportAnchored = <String>{};

/// The app's design size, straight from the composed app_widget.
const Size kDesignSize = Size(375, 812);

// ---------------------------------------------------------------------------
// The demo wiring. Registrations run in composed-app order (base first, then
// the feature SDKs), as main.dart's generated sdk-di block does.
// ---------------------------------------------------------------------------

/// Step 2/8 - the SDK's own demo data. THIS IS THE MAIN PATH.
///
/// PolarisHomeRouteView registers polaris_sdk's own repository and fixture
/// directory itself (in its initState), so this only registers the shared
/// kernel and the auth/user SDKs the home's session reads.
Future<void> registerDemoDependencies() async {
  assert(
      DemoSession.demoActive,
      'demo session not active: the real repositories would call a live '
      'backend and the render is of a broken, empty screen');
  final getIt = GetIt.I;
  BaseSdkDependencies.register(getIt);
  AuthSdkDependencies.register(getIt);
  UsersSdkDependencies.register(getIt);
}

/// Step 3/8 - EXCEPTION: device history the demo mode cannot supply.
///
/// EMPTY. The loan history and the in-flight application are stores the
/// device accumulates through use; the first adoption takes the default path
/// and renders the genuine fresh-device state.
Future<void> seedDeviceHistory(WidgetTester tester) async {}

/// Step 4/8 - EXCEPTION: stub a service with no demo implementation.
///
/// EMPTY. The polaris host route installs its own placeholder wallet bridge
/// (_NoopPolarisWalletBridge) when a demo session starts, so nothing is stubbed.
void registerExceptionStubs() {}

/// Step 5/8 - register sections / routes / gates.
///
/// Nothing to register: the polaris home has no profile-style section
/// registry. The route's own initState does the PolarisSDK wiring.
void registerScreen() {}

/// Step 6/8 - the widget under test.
///
/// The real host route in the real wrapping: ProviderScope, ScreenUtilInit at
/// the app's design size, and a MaterialApp with the app's brightness.
Widget buildScreen({required bool dark}) {
  return ProviderScope(
    child: ScreenUtilInit(
      useInheritedMediaQuery: false,
      designSize: kDesignSize,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: dark ? Brightness.dark : Brightness.light,
          useMaterial3: false,
        ),
        home: const PolarisHomeRouteView(),
      ),
    ),
  );
}

/// Step 7/8 - the elements the review points at.
///
/// `key` is the stable identity the composer binds a number to for the life
/// of the page; the committed map lives in test/render/strip.json. The polaris
/// widgets are matched by runtime type NAME, which the kit's template documents
/// as the supported way for widgets without an importable type in the barrel.
List<ElementSpec> elementSpecs() {
  return <ElementSpec>[
    ElementSpec(
      key: 'polaris.loan_screen',
      label: 'Loan screen - borrower home (loan history, apply, status)',
      finder: find
          .byWidgetPredicate((w) => w.runtimeType.toString() == 'LoanScreen'),
    ),
    ElementSpec(
      key: 'polaris.apply_card',
      label: 'Apply card - start a new loan application',
      finder: find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == 'PolarisApplyCard'),
    ),
    ElementSpec(
      key: 'polaris.loan_status_card',
      label: 'Loan status card - active or latest loan',
      finder: find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == 'PolarisLoanStatusCard'),
    ),
  ];
}

// ---------------------------------------------------------------------------
// Step 8/8 - real fonts.
//
// Without real faces every glyph renders as the Ahem/FlutterTest block font
// and the PNG is worthless, so a missing face is a HARD FAILURE here.
// The faces are COMMITTED under test/render/fonts/, named by the SHA-256
// google_fonts checks each file against, and served back through
// google_fonts' own @visibleForTesting http seam.
// ---------------------------------------------------------------------------

/// Directory holding the committed Google faces. `RENDER_FONT_DIR` points the
/// harness at a different directory for a local experiment.
String _fontDir() {
  final override = Platform.environment['RENDER_FONT_DIR'];
  if (override != null && override.isNotEmpty) return override;
  return '${Directory.current.path}/test/render/fonts';
}

/// Serves google_fonts' own font URLs from the committed faces.
class _OfflineGoogleFontsClient extends http.BaseClient {
  _OfflineGoogleFontsClient(this.fontsDir);

  final Directory fontsDir;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final file = File('${fontsDir.path}/${request.url.pathSegments.last}');
    if (!file.existsSync()) {
      return http.StreamedResponse(
        const Stream<List<int>>.empty(),
        404,
        request: request,
        reasonPhrase:
            'not committed under test/render/fonts - see its README to add it',
      );
    }
    final bytes = file.readAsBytesSync();
    return http.StreamedResponse(
      Stream<List<int>>.value(bytes),
      200,
      contentLength: bytes.length,
      request: request,
    );
  }
}

/// First match for [pattern] under [root], or null. Used to find the icon
/// fonts that ship inside the pub cache, whose paths carry a version.
File? _findFile(Directory root, RegExp pattern) {
  if (!root.existsSync()) return null;
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is File && pattern.hasMatch(entity.path)) return entity;
  }
  return null;
}

Future<void> loadRealFonts() async {
  Future<void> load(String family, List<File> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      final bytes = file.readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  final fontsDir = Directory(_fontDir());
  if (!fontsDir.existsSync()) {
    throw StateError(
      'no committed Google faces at ${fontsDir.path} - every glyph would fall '
      'back to the FlutterTest block font and the render would be worthless.',
    );
  }
  google_fonts_base.httpClient = _OfflineGoogleFontsClient(fontsDir);

  // Warm every face AppStyle asks google_fonts for BEFORE the first pump.
  await GoogleFonts.pendingFonts(<TextStyle>[
    GoogleFonts.inter(fontWeight: FontWeight.w400),
    GoogleFonts.inter(fontWeight: FontWeight.w500),
    GoogleFonts.inter(fontWeight: FontWeight.w600),
    GoogleFonts.inter(fontWeight: FontWeight.w700),
    GoogleFonts.montserrat(fontWeight: FontWeight.w400),
    GoogleFonts.montserrat(fontWeight: FontWeight.w700),
    GoogleFonts.montserrat(fontWeight: FontWeight.w900),
    GoogleFonts.montserrat(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
    ),
    GoogleFonts.montserrat(
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
    ),
    GoogleFonts.montserrat(
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
    ),
  ]);

  // Roboto is never asked for through google_fonts; register it directly.
  final roboto = File(
    '${fontsDir.path}/'
    'd1d7c5f4500eeb1a09e051781906c3642015a3f6c9b69046b905c8bf34c6ad60.ttf',
  );
  if (!roboto.existsSync()) {
    throw StateError('Roboto 400 missing at ${roboto.path} - every bare '
        'TextStyle would render as the FlutterTest block font');
  }
  await load('Roboto', <File>[roboto]);

  // MaterialIcons ships inside the Flutter SDK cache.
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null || flutterRoot.isEmpty) {
    throw StateError('FLUTTER_ROOT is unset, so MaterialIcons cannot be '
        'registered and every icon would render as a blank box');
  }
  await load('MaterialIcons', <File>[
    File('$flutterRoot/bin/cache/artifacts/material_fonts/'
        'MaterialIcons-Regular.otf')
  ]);

  // Remix is the icon set the polaris rows and cards use.
  final pubCache = Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['HOME']}/.pub-cache';
  final remix = _findFile(Directory(pubCache),
      RegExp(r'remixicon-[^/\\]+[/\\]fonts[/\\]Remix\.ttf'));
  if (remix == null) {
    throw StateError('Remix.ttf not found under $pubCache - every Remix icon '
        'on the page would render as a blank box');
  }
  await load('packages/remixicon/Remix', <File>[remix]);
}

/// App-wide state the screen reads before it builds, in main.dart's order.
Future<void> primeAppState({required bool dark}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await LocalStorage.init();
  await LocalStorage.setAppThemeMode(dark);
  await DemoSession.instance.activate();
  AppStyle.setBrightness(dark ? Brightness.dark : Brightness.light);
}

/// The demo persona the tour signs in as (tour/app.tour.yaml setup.demo_email).
/// The auth SDK's `api.user.login` fixture answers for it.
const String kDemoBorrowerEmail = 'customer@demo.rokct.ai';

/// Persists the demo persona the route reads.
///
/// Signs in through the REAL `AuthRepositoryFacade.login`, answered by
/// auth_sdk's fixture, and stores the mapped account through the app's real
/// LocalStorage.setUser. The auth token is left EMPTY on purpose (see the
/// profile harness: a token would reach for connectivity_plus headlessly).
Future<void> persistDemoUser() async {
  final auth = GetIt.I<AuthRepositoryFacade>();
  final result = await auth.login(email: kDemoBorrowerEmail, password: 'demo');
  await result.when(
    success: (data) async {
      final user = data.data?.user;
      if (user == null) {
        throw StateError('the api.user.login fixture returned no user');
      }
      await LocalStorage.setUser(sessionProfileOf(user));
    },
    failure: (error, status) async {
      throw StateError('demo sign-in failed ($status): $error - is the demo '
          'session active and does auth_sdk ship an api.user.login fixture?');
    },
  );
}

// ===========================================================================
// Below here is the proven mechanism (kit template). Leave it alone.
// ===========================================================================

/// One numbered point: a finder, a stable key, and a human label.
class ElementSpec {
  ElementSpec({
    required this.key,
    required this.label,
    required this.finder,
  })  : keyOf = null,
        labelOf = null;

  /// A finder that matches SEVERAL widgets; key and label are derived per match.
  ElementSpec.each({
    required this.keyOf,
    required this.labelOf,
    required this.finder,
  })  : key = '',
        label = '';

  final String key;
  final String label;
  final Finder finder;
  final String Function(int index, Widget widget)? keyOf;
  final String Function(int index, Widget widget)? labelOf;
}

class _Measured {
  _Measured(this.key, this.label, this.rect);

  final String key;
  final String label;
  final Rect rect;
}

/// Mocks the path_provider channel so real drift/sqlite stores can open a
/// database in a temp dir. This is the ONLY platform channel the harness fakes.
void _mockPathProvider(String dir) {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => dir);
}

/// The other channels this harness has to answer. All answer NULL - nothing is
/// simulated, the absent plugin is simply not allowed to throw an unhandled
/// MissingPluginException that aborts the render.
void _mockAbsentPlugins() {
  const channels = <String>[
    'plugins.it_nomads.com/flutter_secure_storage',
    'dev.fluttercommunity.plus/connectivity',
    'dev.fluttercommunity.plus/connectivity_status',
  ];
  for (final name in channels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), (call) async => null);
  }
}

/// Lets REAL async work complete, then pumps frames so the setStates land.
/// `pumpAndSettle` cannot do this: fake-async never runs the real event loop.
Future<void> _drain(WidgetTester tester, {int rounds = 8}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 120)));
    await tester.pump(const Duration(milliseconds: 250));
  }
}

List<_Measured> _measure(WidgetTester tester, List<ElementSpec> specs) {
  final measured = <_Measured>[];
  for (final spec in specs) {
    final elements = spec.finder.evaluate().toList();
    for (var i = 0; i < elements.length; i++) {
      try {
        final widget = elements[i].widget;
        measured.add(_Measured(
          spec.keyOf?.call(i, widget) ?? spec.key,
          spec.labelOf?.call(i, widget) ?? spec.label,
          tester.getRect(spec.finder.at(i)),
        ));
      } catch (_) {
        // Off-stage or unlaid-out matches are skipped rather than failing.
      }
    }
  }

  // Top-to-bottom, then drop wrappers that share a rect with a more specific
  // match (a decorated card whose child is the row we already measured).
  measured.sort((a, b) => a.rect.top.compareTo(b.rect.top));
  final deduped = <_Measured>[];
  for (final item in measured) {
    final clash = deduped.any((kept) =>
        (kept.rect.top - item.rect.top).abs() < 2 &&
        (kept.rect.height - item.rect.height).abs() < 4);
    if (!clash) deduped.add(item);
  }
  return deduped;
}

/// Renders one variant end to end and writes out/<name>.png + out/<name>.json.
Future<void> renderVariant(
  WidgetTester tester, {
  required bool dark,
  required String name,
  required String dbDir,
}) async {
  final outDir = Directory('${Directory.current.path}/out')
    ..createSync(recursive: true);

  _mockPathProvider(dbDir);
  _mockAbsentPlugins();

  await tester.runAsync(_loadRealFontsOnce);

  registerExceptionStubs();
  await tester.runAsync(() => primeAppState(dark: dark));
  await tester.runAsync(registerDemoDependencies);
  await tester.runAsync(persistDemoUser);
  await seedDeviceHistory(tester);
  registerScreen();

  tester.view.physicalSize =
      Size(kLogicalWidth * kDevicePixelRatio, kProbeHeight * kDevicePixelRatio);
  tester.view.devicePixelRatio = kDevicePixelRatio;
  addTearDown(tester.view.reset);

  final boundaryKey = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(
    key: boundaryKey,
    child: buildScreen(dark: dark),
  ));
  await _drain(tester);

  // Pass 1 measures the real content height; pass 2 re-renders at exactly that
  // height. Two passes are REQUIRED: screenutil `.h` sizes scale with the
  // viewport, so the height converges to a fixed point.
  var measured = _measure(tester, elementSpecs());
  expect(measured, isNotEmpty,
      reason: 'no elements matched - check elementSpecs() and the route '
          'the harness pumps');

  final content =
      measured.where((m) => !kViewportAnchored.contains(m.key)).toList();
  if (content.isEmpty) {
    throw StateError('every measured element is viewport-anchored - there is '
        'no content height to shrink to');
  }
  final contentBottom =
      content.map((m) => m.rect.bottom).reduce((a, b) => a > b ? a : b);
  final bottomChrome = measured
      .where((m) => kViewportAnchored.contains(m.key))
      .fold<double>(0, (a, m) => a > m.rect.height ? a : m.rect.height);
  final targetHeight = (contentBottom + bottomChrome + kBottomPadding)
      .clamp(400.0, kProbeHeight);

  tester.view.physicalSize =
      Size(kLogicalWidth * kDevicePixelRatio, targetHeight * kDevicePixelRatio);
  await tester.pump(const Duration(milliseconds: 50));
  await _drain(tester, rounds: 4);
  measured = _measure(tester, elementSpecs());

  await tester.runAsync(() async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: kDevicePixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('${outDir.path}/$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());

    // Sidecar consumed by scripts/render/compose_strip.py.
    final sidecar = <String, Object?>{
      'variant': name,
      'logicalWidth': kLogicalWidth,
      'logicalHeight': targetHeight,
      'devicePixelRatio': kDevicePixelRatio,
      'elements': <Object>[
        for (var i = 0; i < measured.length; i++)
          <String, Object?>{
            'number': i + 1,
            'key': measured[i].key,
            'label': measured[i].label,
            'x': measured[i].rect.left,
            'y': measured[i].rect.top,
            'w': measured[i].rect.width,
            'h': measured[i].rect.height,
          }
      ],
    };
    File('${outDir.path}/$name.json')
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(sidecar));
  });
}

bool _fontsLoaded = false;
Future<void> _loadRealFontsOnce() async {
  if (_fontsLoaded) return;
  await loadRealFonts();
  _fontsLoaded = true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Fetching stays ON, but loadRealFonts swaps google_fonts' http client for
  // one that only answers from the committed faces. Nothing reaches the network.
  GoogleFonts.config.allowRuntimeFetching = true;

  final dbDir = Directory.systemTemp.createTempSync('render_harness_db').path;

  // RENDER_SUFFIX distinguishes runs of the SAME harness against different
  // checkouts, so both sets of outputs can sit in one out/ dir.
  final suffix = Platform.environment['RENDER_SUFFIX'] ?? '';

  testWidgets('render polaris borrower home - dark (app default)',
      (tester) async {
    await renderVariant(tester,
        dark: true, name: 'polaris_borrower_home_dark$suffix', dbDir: dbDir);
  });

  testWidgets('render polaris borrower home - light', (tester) async {
    await renderVariant(tester,
        dark: false, name: 'polaris_borrower_home_light$suffix', dbDir: dbDir);
  });
}
