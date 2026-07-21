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
];

EconomyTopic? topicById(String id) {
  for (final t in kEconomyTopics) {
    if (t.id == id) return t;
  }
  return null;
}
