package com.family.son_allowance_app

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth(생체인증)는 BiometricPrompt를 붙일 FragmentActivity가 필요하다.
// 평범한 FlutterActivity로는 인증창이 뜨지 않고 조용히 실패한다.
class MainActivity : FlutterFragmentActivity()
