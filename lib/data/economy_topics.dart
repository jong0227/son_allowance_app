/// 경제상식 한 꼭지(설명 화면의 한 단락).
class TopicSection {
  final String emoji;
  final String title;
  final String body;
  const TopicSection({required this.emoji, required this.title, required this.body});
}

/// 경제왕 탭에서 읽는 경제상식 주제.
/// 초등 저학년 눈높이 — 짧은 문장 + 생활 속 비유.
class EconomyTopic {
  final String id;
  final String emoji;
  final String title;
  final String summary; // 목록 카드에 보이는 한 줄
  final List<TopicSection> sections;
  final String callout; // 마무리 한마디

  const EconomyTopic({
    required this.id,
    required this.emoji,
    required this.title,
    required this.summary,
    required this.sections,
    required this.callout,
  });
}

const List<EconomyTopic> kEconomyTopics = [
  EconomyTopic(
    id: 'saving',
    emoji: '🐷',
    title: '저축이 뭐야?',
    summary: '쓰지 않고 모으면 생기는 힘',
    sections: [
      TopicSection(
        emoji: '🍪',
        title: '지금 참으면 나중에 더 커져요',
        body: '과자 하나를 참으면 그 돈이 남아요. 그게 쌓이면 훨씬 큰 걸 살 수 있어요. '
            '저축은 "미래의 나에게 주는 선물"이에요.',
      ),
      TopicSection(
        emoji: '🎯',
        title: '목표를 정하면 쉬워져요',
        body: '그냥 모으는 것보다 "자전거 사기"처럼 목표가 있으면 참는 힘이 생겨요. '
            '얼마가 필요한지 먼저 알아보세요.',
      ),
      TopicSection(
        emoji: '✂️',
        title: '먼저 떼어놓기',
        body: '쓰고 남은 걸 모으면 잘 안 모여요. 용돈을 받자마자 저축할 몫을 먼저 떼어놓는 게 비결이에요.',
      ),
    ],
    callout: '모아둔 돈에는 이자가 붙어요. 모을수록 이자도 커진답니다!',
  ),
  EconomyTopic(
    id: 'inflation',
    emoji: '🎈',
    title: '물가가 뭐야?',
    summary: '작년 1,000원 과자가 올해 1,200원인 이유',
    sections: [
      TopicSection(
        emoji: '🍬',
        title: '물건 값이 오르는 것',
        body: '작년엔 1,000원이던 과자가 올해 1,200원이 됐다면, 물가가 오른 거예요. '
            '과자만이 아니라 여러 물건 값이 같이 올라요.',
      ),
      TopicSection(
        emoji: '💸',
        title: '돈의 힘이 약해져요',
        body: '값이 오르면 같은 1,000원으로 살 수 있는 게 줄어요. '
            '돈은 그대로인데 살 수 있는 게 적어지니, 돈의 힘이 약해진 거예요.',
      ),
      TopicSection(
        emoji: '🏃',
        title: '그래서 이자와 투자가 필요해요',
        body: '돈을 그냥 두면 물가에 밀려요. 이자를 받거나 잘 투자하면 물가를 따라잡을 수 있어요.',
      ),
    ],
    callout: '저축 이자가 물가보다 높으면, 내 돈이 진짜로 커지는 거예요!',
  ),
  EconomyTopic(
    id: 'stock',
    emoji: '🏢',
    title: '주식이 뭐야?',
    summary: '회사를 작게 나눈 조각',
    sections: [
      TopicSection(
        emoji: '🍕',
        title: '회사를 피자처럼 나눈 조각',
        body: '큰 회사를 아주 작은 조각으로 나눈 것이 주식이에요. '
            '그 조각을 사면 나도 그 회사의 작은 주인이 돼요.',
      ),
      TopicSection(
        emoji: '📈',
        title: '값은 오르내려요',
        body: '회사가 잘되면 조각 값도 오르고, 어려우면 내려가요. '
            '그래서 돈을 벌 수도, 잃을 수도 있어요.',
      ),
      TopicSection(
        emoji: '🧺',
        title: '한 바구니에 담지 않기',
        body: '한 회사에 전부 넣으면 위험해요. 여러 개로 나누고, 잘 아는 회사부터 조금씩 시작해요.',
      ),
    ],
    callout: '코스피는 우리나라 회사들의 평균 성적표예요. 홈에서 매일 볼 수 있어요!',
  ),
  EconomyTopic(
    id: 'fx',
    emoji: '🌍',
    title: '환율이 뭐야?',
    summary: '나라마다 다른 돈을 바꾸는 비율',
    sections: [
      TopicSection(
        emoji: '💵',
        title: '나라마다 돈이 달라요',
        body: '우리나라는 원, 미국은 달러를 써요. 미국 물건을 사려면 원을 달러로 바꿔야 해요.',
      ),
      TopicSection(
        emoji: '⚖️',
        title: '바꾸는 비율이 환율',
        body: '1달러를 사려면 우리 돈이 얼마나 필요한지 알려주는 숫자가 환율이에요. '
            '1달러가 1,380원이면 환율이 1,380원인 거예요.',
      ),
      TopicSection(
        emoji: '🎢',
        title: '환율도 오르내려요',
        body: '환율이 오르면 달러가 비싸진 거예요. 미국 주식을 살 때 돈이 더 필요해져요.',
      ),
    ],
    callout: '서원이가 미국 주식을 살 때 바로 이 환율이 쓰여요!',
  ),
  EconomyTopic(
    id: 'opportunity',
    emoji: '🤷',
    title: '기회비용이 뭐야?',
    summary: '하나를 고르면 포기하는 다른 하나',
    sections: [
      TopicSection(
        emoji: '🍦',
        title: '고르면 포기하는 게 생겨요',
        body: '3,000원으로 아이스크림을 사면 그 돈으로 살 수 있던 다른 것은 못 사요. '
            '그 포기한 것이 기회비용이에요.',
      ),
      TopicSection(
        emoji: '🧠',
        title: '똑똑하게 고르는 법',
        body: '금방 없어지는 것과 오래 좋아할 것 중에 어떤 게 나을까 생각해보세요. '
            '"이걸 사면 뭘 못 사지?" 한 번만 물어보면 돼요.',
      ),
    ],
    callout: '돈은 한정돼 있어요. 그래서 무엇이 더 중요한지 정하는 힘이 필요해요.',
  ),
  EconomyTopic(
    id: 'bank',
    emoji: '🏦',
    title: '은행은 뭘 할까?',
    summary: '돈을 맡아주고, 빌려주는 곳',
    sections: [
      TopicSection(
        emoji: '🔐',
        title: '돈을 안전하게 맡아줘요',
        body: '집에 두면 잃어버릴 수도 있죠. 은행은 돈을 안전하게 보관해줘요.',
      ),
      TopicSection(
        emoji: '🤝',
        title: '필요한 사람에게 빌려줘요',
        body: '맡은 돈을 집이 필요한 사람, 가게를 열 사람에게 빌려주고 이자를 받아요. '
            '그 이자의 일부를 돈 맡긴 사람에게 나눠주는 게 예금 이자예요.',
      ),
      TopicSection(
        emoji: '🛡️',
        title: '예금자보호',
        body: '혹시 은행에 문제가 생겨도, 나라가 정한 금액까지는 돌려받을 수 있게 지켜줘요. '
            '이걸 예금자보호라고 해요.',
      ),
    ],
    callout: '빌린 돈은 꼭 약속한 날까지 갚아야 해요. 늦으면 이자를 더 내야 해요.',
  ),
  EconomyTopic(
    id: 'needs_wants',
    emoji: '🛒',
    title: '필요와 욕구',
    summary: '꼭 있어야 하는 것 vs 있으면 좋은 것',
    sections: [
      TopicSection(
        emoji: '🍚',
        title: '필요 — 없으면 안 되는 것',
        body: '밥, 옷, 잠잘 곳처럼 살아가는 데 꼭 있어야 하는 것이 필요예요.',
      ),
      TopicSection(
        emoji: '🎮',
        title: '욕구 — 있으면 좋은 것',
        body: '최신 게임기, 예쁜 스티커처럼 없어도 살 수 있지만 갖고 싶은 게 욕구예요.',
      ),
      TopicSection(
        emoji: '🤔',
        title: '사기 전에 한 번 묻기',
        body: '"이게 필요일까, 욕구일까?" 한 번만 생각해도 후회하는 소비를 줄일 수 있어요.',
      ),
    ],
    callout: '필요를 먼저 챙기고, 욕구는 모아서 목표로 사면 훨씬 똑똑한 소비가 돼요!',
  ),
  EconomyTopic(
    id: 'smart_spending',
    emoji: '🧠',
    title: '현명한 소비',
    summary: '광고와 충동구매에 넘어가지 않기',
    sections: [
      TopicSection(
        emoji: '📺',
        title: '광고는 사고 싶게 만들어요',
        body: '광고는 물건을 멋지게 보이게 해요. 그래도 "나에게 필요한가?"는 내가 정해야 해요.',
      ),
      TopicSection(
        emoji: '⚡',
        title: '충동구매를 조심해요',
        body: '갑자기 사고 싶어도 잠깐 멈춰요. 하루만 기다리면 안 사도 되는 경우가 많아요.',
      ),
      TopicSection(
        emoji: '🔎',
        title: '값을 비교해요',
        body: '같은 물건도 가게마다 값이 달라요. 비교해서 싸게 사면 돈이 남아요.',
      ),
    ],
    callout: '필요한지 → 값 비교 → 결정! 이 순서만 지켜도 소비 고수예요.',
  ),
  EconomyTopic(
    id: 'budget',
    emoji: '📊',
    title: '용돈 관리와 예산',
    summary: '쓸 돈을 미리 계획하는 힘',
    sections: [
      TopicSection(
        emoji: '🧮',
        title: '예산 — 미리 정하는 계획',
        body: '얼마를 어디에 쓸지 미리 정하는 게 예산이에요. 계획하면 돈이 새지 않아요.',
      ),
      TopicSection(
        emoji: '3️⃣',
        title: '쓸 돈·모을 돈·나눌 돈',
        body: '용돈을 세 몫으로 나눠보세요. 쓰기도, 모으기도, 나누기도 균형 있게 할 수 있어요.',
      ),
      TopicSection(
        emoji: '📒',
        title: '적어두면 보여요',
        body: '용돈 기입장에 적으면 "내 돈이 어디로 갔지?"를 알 수 있어 다음에 더 잘 써요.',
      ),
    ],
    callout: '용돈을 받으면 저축할 몫을 가장 먼저 떼어놓는 게 비결이에요!',
  ),
  EconomyTopic(
    id: 'compound',
    emoji: '⏳',
    title: '복리가 뭐야?',
    summary: '이자에 또 이자가 붙는 마법',
    sections: [
      TopicSection(
        emoji: '❄️',
        title: '눈덩이처럼 불어나요',
        body: '받은 이자에 또 이자가 붙는 걸 복리라고 해요. 작은 눈덩이가 굴러 커지는 것과 같아요.',
      ),
      TopicSection(
        emoji: '🕰️',
        title: '오래 둘수록 커져요',
        body: '복리는 시간이 친구예요. 안 쓰고 오래 둘수록 훨씬 크게 불어나요.',
      ),
      TopicSection(
        emoji: '📈',
        title: '얼마나 모일까 탭에서 보기',
        body: '경제왕 탭의 "얼마나 모일까?"에서 복리로 돈이 불어나는 걸 그래프로 볼 수 있어요.',
      ),
    ],
    callout: '일찍 시작하고 오래 두는 것 — 이게 복리를 내 편으로 만드는 방법이에요!',
  ),
  EconomyTopic(
    id: 'credit',
    emoji: '🤝',
    title: '신용과 빚',
    summary: '빌린 돈과 믿음 이야기',
    sections: [
      TopicSection(
        emoji: '💳',
        title: '빚 — 갚아야 할 빌린 돈',
        body: '남에게 빌린 돈이 빚이에요. 약속한 날까지 이자를 얹어서 꼭 갚아야 해요.',
      ),
      TopicSection(
        emoji: '⭐',
        title: '신용 — 믿음이라는 재산',
        body: '빌린 돈을 잘 갚고 약속을 지키면 신용이 좋아져요. 믿음도 소중한 재산이에요.',
      ),
      TopicSection(
        emoji: '⏰',
        title: '늦으면 손해예요',
        body: '제때 못 갚으면 이자가 더 붙고 신용도 떨어져요. 그래서 빚은 신중해야 해요.',
      ),
    ],
    callout: '갚을 수 있는 만큼만! 빚은 작게, 약속은 확실하게가 규칙이에요.',
  ),
  EconomyTopic(
    id: 'tax',
    emoji: '🏛️',
    title: '세금이 뭐야?',
    summary: '다 함께 쓰려고 모으는 돈',
    sections: [
      TopicSection(
        emoji: '🚒',
        title: '모두를 위한 돈',
        body: '세금은 학교, 도로, 공원, 소방차처럼 다 같이 쓰는 데 쓰여요.',
      ),
      TopicSection(
        emoji: '🍫',
        title: '물건값에도 숨어 있어요',
        body: '과자를 사면 값에 부가세라는 세금이 살짝 들어있어요. 우리도 모르게 참여하는 거예요.',
      ),
      TopicSection(
        emoji: '💼',
        title: '어른들은 번 돈에서 내요',
        body: '어른들은 일해서 번 돈의 일부를 세금으로 내요. 그 돈으로 나라가 움직여요.',
      ),
    ],
    callout: '세금은 우리 모두가 함께 잘 살기 위해 모으는 돈이에요.',
  ),
  EconomyTopic(
    id: 'sharing',
    emoji: '💝',
    title: '나눔과 기부',
    summary: '함께 쓰면 커지는 행복',
    sections: [
      TopicSection(
        emoji: '🤲',
        title: '기부 — 나누는 것',
        body: '내 돈의 일부를 어려운 이웃을 위해 나누는 게 기부예요. 작은 나눔도 큰 힘이 돼요.',
      ),
      TopicSection(
        emoji: '😊',
        title: '나도 뿌듯해져요',
        body: '나눔은 남도 돕고 내 마음도 따뜻해지는 멋진 소비예요.',
      ),
      TopicSection(
        emoji: '🎯',
        title: '나눌 몫을 정해두기',
        body: '용돈에서 "나눌 돈"을 미리 정해두면 꾸준히 나눌 수 있어요.',
      ),
    ],
    callout: '쓰고, 모으고, 나누고 — 이 셋이 균형을 이루면 진짜 부자예요!',
  ),
  EconomyTopic(
    id: 'money',
    emoji: '🪙',
    title: '돈은 어디서 올까?',
    summary: '돈의 시작과 버는 방법',
    sections: [
      TopicSection(
        emoji: '🔄',
        title: '물건을 바꾸려고 생겼어요',
        body: '옛날엔 물건끼리 바꿨는데 불편했어요. 그래서 편하게 바꾸려고 돈이 생겼어요.',
      ),
      TopicSection(
        emoji: '💪',
        title: '일한 대가로 벌어요',
        body: '어른들은 일(노동)을 해서 돈을 벌어요. 돈은 노력의 열매예요.',
      ),
      TopicSection(
        emoji: '🏪',
        title: '만들어 팔아서도 벌어요',
        body: '좋은 물건이나 서비스를 만들어 파는 사람(사업가)도 돈을 벌 수 있어요.',
      ),
    ],
    callout: '"공짜로 큰돈을 준다"는 말은 조심! 세상에 그런 돈은 거의 없어요.',
  ),
  EconomyTopic(
    id: 'safety',
    emoji: '🔒',
    title: '돈을 안전하게 지키기',
    summary: '사기에 속지 않는 법',
    sections: [
      TopicSection(
        emoji: '🤫',
        title: '비밀번호는 나만',
        body: '비밀번호는 누가 물어봐도 알려주면 안 돼요. 나만 아는 비밀이에요.',
      ),
      TopicSection(
        emoji: '🎣',
        title: '"돈부터 보내"는 조심',
        body: '싸게 준다며 돈부터 보내라는 건 사기일 때가 많아요. 꼭 어른과 확인해요.',
      ),
      TopicSection(
        emoji: '📦',
        title: '안전하게 두고 기록하기',
        body: '돈과 통장은 안전한 곳에 두고, 얼마 있는지 적어두면 잃어버리지 않아요.',
      ),
    ],
    callout: '이상하면 멈추고 어른께 물어보기 — 이게 최고의 안전 규칙이에요!',
  ),
  EconomyTopic(
    id: 'invest',
    emoji: '🌱',
    title: '투자와 위험',
    summary: '돈을 키우는 법과 조심할 점',
    sections: [
      TopicSection(
        emoji: '🏢',
        title: '투자 — 돈이 일하게 하기',
        body: '주식처럼 좋은 곳에 돈을 넣어 함께 자라길 기다리는 게 투자예요.',
      ),
      TopicSection(
        emoji: '🎢',
        title: '위험 — 잃을 수도 있어요',
        body: '값이 내리면 돈을 잃을 수도 있어요. 그래서 잃어도 되는 만큼만, 잘 알아보고 해요.',
      ),
      TopicSection(
        emoji: '🧺',
        title: '나눠 담기',
        body: '한 곳에 다 넣지 말고 여러 곳에 나누면 위험이 줄어요. "한 바구니에 담지 마라"예요.',
      ),
    ],
    callout: '저축은 안전하게, 투자는 조금씩 배우면서 — 둘 다 내 편으로 만들어요!',
  ),
];

EconomyTopic? topicById(String id) {
  for (final t in kEconomyTopics) {
    if (t.id == id) return t;
  }
  return null;
}
