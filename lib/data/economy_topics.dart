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
    id: 'needwant',
    emoji: '🧐',
    title: '필요한 것 vs 갖고 싶은 것',
    summary: '없으면 안 되는 것과, 있으면 좋은 것',
    sections: [
      TopicSection(
        emoji: '🥛',
        title: '필요한 것',
        body: '없으면 곤란한 것이에요. 밥, 학용품, 신발처럼요. 이건 먼저 챙겨야 해요.',
      ),
      TopicSection(
        emoji: '🎮',
        title: '갖고 싶은 것',
        body: '없어도 살 수 있지만 있으면 즐거운 것이에요. 게임, 장난감, 간식처럼요.',
      ),
      TopicSection(
        emoji: '⚖️',
        title: '순서를 정해요',
        body: '필요한 것을 먼저 챙기고 남은 돈으로 갖고 싶은 걸 사면 후회가 적어요.',
      ),
    ],
    callout: '"이거 없으면 진짜 곤란할까?" 한 번만 물어보면 답이 나와요.',
  ),
  EconomyTopic(
    id: 'ads',
    emoji: '📺',
    title: '광고는 왜 있을까?',
    summary: '사고 싶게 만드는 기술',
    sections: [
      TopicSection(
        emoji: '✨',
        title: '광고는 제일 좋은 모습만 보여줘요',
        body: '광고 속 장난감은 반짝반짝하고 재밌어 보여요. 하지만 실제로 받아보면 다를 수 있어요.',
      ),
      TopicSection(
        emoji: '⏰',
        title: '하루만 기다려보기',
        body: '갑자기 사고 싶어질 땐 하루만 참아보세요. 다음 날에도 갖고 싶으면 진짜 원하는 거예요.',
      ),
    ],
    callout: '광고를 보고 사고 싶어지는 건 자연스러워요. 잠깐 멈추는 힘이 중요해요.',
  ),
  EconomyTopic(
    id: 'compound',
    emoji: '⛄',
    title: '복리가 뭐야?',
    summary: '이자에 또 이자가 붙는 눈덩이',
    sections: [
      TopicSection(
        emoji: '❄️',
        title: '작은 눈덩이가 커져요',
        body: '눈덩이를 굴리면 처음엔 천천히 커지다가 나중엔 순식간에 커지죠? 돈도 똑같아요.',
      ),
      TopicSection(
        emoji: '🔁',
        title: '이자가 또 이자를 낳아요',
        body: '이번 주에 받은 이자도 잔액이 돼요. 다음 주엔 그 이자에도 이자가 붙어요.',
      ),
      TopicSection(
        emoji: '⏳',
        title: '시간이 힘이에요',
        body: '오래 둘수록 훨씬 빨리 커져요. 그래서 일찍 시작하는 게 좋아요.',
      ),
    ],
    callout: '경제왕 탭의 "얼마나 모일까?"에서 눈덩이가 커지는 걸 직접 볼 수 있어요!',
  ),
  EconomyTopic(
    id: 'tax',
    emoji: '🏫',
    title: '세금이 뭐야?',
    summary: '다 같이 쓰는 것을 만드는 돈',
    sections: [
      TopicSection(
        emoji: '🤝',
        title: '모두가 조금씩 내는 돈',
        body: '어른들이 번 돈에서 조금씩 나라에 내는 돈이 세금이에요.',
      ),
      TopicSection(
        emoji: '🛣️',
        title: '함께 쓰는 것에 써요',
        body: '학교, 도로, 병원, 소방차처럼 모두가 함께 쓰는 것을 만드는 데 써요. 혼자서는 못 만드니까요.',
      ),
    ],
    callout: '서원이가 다니는 학교도 세금으로 지어진 거예요.',
  ),
  EconomyTopic(
    id: 'risk',
    emoji: '🧺',
    title: '한 바구니에 담지 마',
    summary: '위험을 나누는 방법',
    sections: [
      TopicSection(
        emoji: '🥚',
        title: '달걀을 한 바구니에 담으면',
        body: '바구니를 떨어뜨리면 달걀이 다 깨져요. 나눠 담으면 하나가 떨어져도 나머지는 무사해요.',
      ),
      TopicSection(
        emoji: '📊',
        title: '돈도 나눠서',
        body: '한 회사 주식에 전부 넣으면 그 회사가 어려울 때 크게 잃어요. 여러 개로 나누면 안전해요.',
      ),
    ],
    callout: '"몰빵"은 위험해요. 나누는 게 똑똑한 방법이에요.',
  ),
  EconomyTopic(
    id: 'giving',
    emoji: '💝',
    title: '나눔이 뭐야?',
    summary: '돈으로 할 수 있는 따뜻한 일',
    sections: [
      TopicSection(
        emoji: '🎁',
        title: '나눠도 줄지 않는 것',
        body: '돈을 나누면 내 돈은 줄지만, 마음은 오히려 커져요. 도움받은 사람의 하루가 달라지거든요.',
      ),
      TopicSection(
        emoji: '🌱',
        title: '작아도 괜찮아요',
        body: '큰돈이 아니어도 돼요. 100원도 모이면 누군가에게 큰 도움이 돼요.',
      ),
    ],
    callout: '돈을 모으는 이유엔 "나를 위해"도 있고 "다른 사람을 위해"도 있어요.',
  ),
  EconomyTopic(
    id: 'promise',
    emoji: '🤞',
    title: '신용이 뭐야?',
    summary: '약속을 지키면 쌓이는 믿음',
    sections: [
      TopicSection(
        emoji: '📒',
        title: '약속을 지킨 기록',
        body: '빌린 돈을 제때 갚고 약속을 지키면 "믿을 수 있는 사람"이 돼요. 그게 신용이에요.',
      ),
      TopicSection(
        emoji: '🚪',
        title: '신용이 있으면 문이 열려요',
        body: '어른이 되면 신용이 좋아야 집을 살 때 은행이 돈을 빌려줘요. 신용이 나쁘면 안 빌려주거나 이자를 더 받아요.',
      ),
    ],
    callout: '지금 부모님과의 약속을 지키는 것도 신용을 쌓는 연습이에요!',
  ),
  EconomyTopic(
    id: 'budget',
    emoji: '📝',
    title: '용돈 계획 세우기',
    summary: '쓰기 전에 정해두면 안 흔들려요',
    sections: [
      TopicSection(
        emoji: '🍰',
        title: '용돈을 세 조각으로',
        body: '받자마자 "저축할 돈 / 쓸 돈 / 나눌 돈"으로 나눠보세요. 남은 걸 모으는 것보다 훨씬 잘 모여요.',
      ),
      TopicSection(
        emoji: '✍️',
        title: '적어두기',
        body: '어디에 썼는지 적으면 내가 어디에 많이 쓰는지 보여요. 그래야 줄일 곳을 알 수 있어요.',
      ),
    ],
    callout: '앱의 "이번 주 예산"이 바로 이 계획을 도와주는 기능이에요.',
  ),
];

EconomyTopic? topicById(String id) {
  for (final t in kEconomyTopics) {
    if (t.id == id) return t;
  }
  return null;
}
