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

  // ================= 초등 고학년(3~6학년) 심화 =================
  EconomyTopic(
    id: 'supply_demand',
    emoji: '⚖️',
    title: '수요와 공급',
    summary: '값이 오르내리는 진짜 이유',
    sections: [
      TopicSection(
        emoji: '🙋',
        title: '수요 — 사고 싶은 마음',
        body: '사람들이 그 물건을 얼마나 사고 싶어 하는지가 수요예요. '
            '인기가 많아 사려는 사람이 늘면 수요가 늘었다고 해요.',
      ),
      TopicSection(
        emoji: '📦',
        title: '공급 — 팔 수 있는 양',
        body: '시장에 나와 있는 물건의 양이 공급이에요. '
            '많이 만들면 공급이 늘고, 적게 만들면 공급이 줄어요.',
      ),
      TopicSection(
        emoji: '🔀',
        title: '둘이 만나 값이 정해져요',
        body: '사려는 사람은 많은데 물건이 적으면 값이 올라요. '
            '반대로 물건은 많은데 사려는 사람이 적으면 값이 내려가요.',
      ),
    ],
    callout: '한정판 신발이 비싼 이유! 수요는 많은데 공급이 적기 때문이에요.',
  ),
  EconomyTopic(
    id: 'competition',
    emoji: '🏁',
    title: '경쟁과 독점',
    summary: '가게가 여럿일 때 vs 하나뿐일 때',
    sections: [
      TopicSection(
        emoji: '🏪',
        title: '경쟁하면 소비자가 좋아요',
        body: '같은 물건을 파는 가게가 여럿이면 서로 더 싸고 좋게 팔려고 해요. '
            '그래서 값이 내려가고 품질이 좋아져요.',
      ),
      TopicSection(
        emoji: '👑',
        title: '독점 — 혼자만 파는 것',
        body: '한 회사만 팔면 값을 마음대로 올려도 살 수밖에 없어요. '
            '이걸 독점이라고 하고, 소비자에게 불리해요.',
      ),
      TopicSection(
        emoji: '🛡️',
        title: '나라가 지켜봐요',
        body: '독점으로 값을 부당하게 올리지 못하게 나라가 규칙을 만들고 감시해요.',
      ),
    ],
    callout: '학교 앞 문구점이 하나뿐일 때와 여럿일 때, 값이 어떻게 다를지 생각해보세요.',
  ),
  EconomyTopic(
    id: 'gdp',
    emoji: '🏭',
    title: 'GDP가 뭐야?',
    summary: '나라가 1년에 만들어낸 것의 총합',
    sections: [
      TopicSection(
        emoji: '📏',
        title: '나라의 성적표',
        body: '한 나라에서 1년 동안 새로 만들어낸 물건과 서비스의 값을 모두 더한 것이 '
            'GDP(국내총생산)예요.',
      ),
      TopicSection(
        emoji: '📈',
        title: 'GDP가 늘면 경제가 자란 것',
        body: 'GDP가 작년보다 늘면 경제가 성장했다고 해요. '
            '일자리도 늘고 사람들 소득도 보통 함께 늘어요.',
      ),
      TopicSection(
        emoji: '👨‍👩‍👧',
        title: '1인당 GDP',
        body: 'GDP를 인구수로 나누면 1인당 GDP예요. '
            '나라 크기와 상관없이 한 사람당 얼마나 잘사는지 비교할 때 써요.',
      ),
    ],
    callout: 'GDP는 나라 경제의 크기를 재는 자예요.',
  ),
  EconomyTopic(
    id: 'business_cycle',
    emoji: '🎢',
    title: '호황과 불황',
    summary: '경제도 오르막 내리막이 있어요',
    sections: [
      TopicSection(
        emoji: '☀️',
        title: '호황 — 잘 돌아갈 때',
        body: '사람들이 물건을 많이 사고 회사도 잘되고 일자리도 많은 시기예요.',
      ),
      TopicSection(
        emoji: '🌧️',
        title: '불황 — 어려울 때',
        body: '사람들이 돈을 안 쓰고 회사도 어려워져 일자리가 줄어드는 시기예요.',
      ),
      TopicSection(
        emoji: '🔁',
        title: '오르내림이 반복돼요',
        body: '경제는 호황과 불황을 번갈아 겪어요. 이걸 경기 순환이라고 해요. '
            '그래서 불황이 와도 언젠가 다시 좋아져요.',
      ),
    ],
    callout: '불황일 때 미리 모아둔 돈이 큰 힘이 돼요. 그래서 저축이 중요해요!',
  ),
  EconomyTopic(
    id: 'central_bank',
    emoji: '🏛️',
    title: '중앙은행이 하는 일',
    summary: '한국은행은 왜 특별할까',
    sections: [
      TopicSection(
        emoji: '💵',
        title: '돈을 찍어내는 곳',
        body: '우리나라 지폐와 동전을 만드는 곳이 한국은행이에요. '
            '은행들의 은행이라 개인은 통장을 만들 수 없어요.',
      ),
      TopicSection(
        emoji: '🎚️',
        title: '기준금리를 정해요',
        body: '물가가 너무 오르면 기준금리를 올려 돈을 덜 쓰게 하고, '
            '경제가 어려우면 내려서 돈을 더 쓰게 해요.',
      ),
      TopicSection(
        emoji: '🎯',
        title: '물가를 지켜요',
        body: '중앙은행의 가장 큰 목표는 물가를 안정시키는 거예요. '
            '값이 널뛰면 사람들이 계획을 세울 수 없거든요.',
      ),
    ],
    callout: '기준금리 뉴스가 나오면 물가를 조절하려는구나 생각하면 돼요.',
  ),
  EconomyTopic(
    id: 'money_value',
    emoji: '🎈',
    title: '돈이 많아지면?',
    summary: '통화량과 돈의 가치',
    sections: [
      TopicSection(
        emoji: '🖨️',
        title: '돈을 많이 찍으면 부자가 될까?',
        body: '아니에요. 세상에 돈이 갑자기 많아지면 돈 하나하나의 가치가 떨어져요. '
            '물건은 그대로인데 돈만 많아지니 값이 오르는 거예요.',
      ),
      TopicSection(
        emoji: '🥖',
        title: '하이퍼인플레이션',
        body: '실제로 돈을 너무 많이 찍어서 빵 한 개에 수백만 원이 된 나라도 있었어요.',
      ),
      TopicSection(
        emoji: '⚖️',
        title: '그래서 조절해요',
        body: '중앙은행은 세상에 도는 돈의 양(통화량)을 적당하게 유지하려고 애써요.',
      ),
    ],
    callout: '돈의 가치는 얼마나 희귀한가에 달려 있어요. 금이 비싼 이유와 같아요.',
  ),
  EconomyTopic(
    id: 'deflation',
    emoji: '❄️',
    title: '디플레이션',
    summary: '값이 내리는 게 꼭 좋을까?',
    sections: [
      TopicSection(
        emoji: '📉',
        title: '물가가 계속 내려가는 것',
        body: '인플레이션의 반대예요. 물건값이 전체적으로 계속 떨어지는 상태를 말해요.',
      ),
      TopicSection(
        emoji: '⏳',
        title: '왜 나쁠까?',
        body: '내일 더 싸질 텐데 하며 아무도 안 사면 회사가 물건을 못 팔아요. '
            '그러면 일자리가 줄고 경제가 얼어붙어요.',
      ),
      TopicSection(
        emoji: '🎯',
        title: '적당한 물가 상승이 좋아요',
        body: '그래서 나라들은 물가를 매년 2%쯤 완만하게 올리는 걸 목표로 삼아요.',
      ),
    ],
    callout: '값이 싸지는 게 무조건 좋은 건 아니에요. 경제는 균형이 중요해요.',
  ),
  EconomyTopic(
    id: 'fx_deep',
    emoji: '🌐',
    title: '환율은 왜 움직일까',
    summary: '달러가 비싸지고 싸지는 이유',
    sections: [
      TopicSection(
        emoji: '🤲',
        title: '달러도 수요와 공급',
        body: '달러를 사려는 사람이 많으면 달러값(환율)이 올라요. '
            '우리 물건을 많이 수출하면 달러가 들어와 환율이 내려가요.',
      ),
      TopicSection(
        emoji: '🛡️',
        title: '불안하면 달러로 몰려요',
        body: '전쟁이나 위기가 오면 사람들이 안전하다고 여기는 달러를 사서 환율이 올라요.',
      ),
      TopicSection(
        emoji: '⚖️',
        title: '환율이 오르면 좋을까 나쁠까',
        body: '수출 회사는 유리하고, 수입 물건이나 해외여행은 비싸져요. '
            '좋고 나쁨이 반반이에요.',
      ),
    ],
    callout: '환율은 우리 경제와 세계 경제를 잇는 다리예요.',
  ),
  EconomyTopic(
    id: 'trade',
    emoji: '🚢',
    title: '무역 — 수출과 수입',
    summary: '나라끼리 사고파는 것',
    sections: [
      TopicSection(
        emoji: '📤',
        title: '수출 — 우리가 파는 것',
        body: '우리나라 물건을 외국에 파는 것이 수출이에요. 반도체, 자동차, 배가 대표적이에요.',
      ),
      TopicSection(
        emoji: '📥',
        title: '수입 — 우리가 사는 것',
        body: '외국 물건을 사오는 것이 수입이에요. 우리나라는 석유, 밀 같은 걸 수입해요.',
      ),
      TopicSection(
        emoji: '🤝',
        title: '서로에게 이득이에요',
        body: '각 나라가 잘 만드는 걸 만들어 바꾸면 모두가 더 좋은 걸 싸게 쓸 수 있어요.',
      ),
    ],
    callout: '우리나라는 자원이 적어서 무역이 특히 중요한 나라예요.',
  ),
  EconomyTopic(
    id: 'comparative_advantage',
    emoji: '🎯',
    title: '잘하는 걸 맡아요',
    summary: '비교우위 — 무역이 이득인 이유',
    sections: [
      TopicSection(
        emoji: '👩‍🍳',
        title: '각자 더 잘하는 게 있어요',
        body: '엄마가 요리도 설거지도 나보다 빠르대도, 엄마가 요리하고 내가 설거지하면 '
            '집안일이 더 빨리 끝나요.',
      ),
      TopicSection(
        emoji: '🌍',
        title: '나라도 마찬가지예요',
        body: '우리나라는 반도체를, 다른 나라는 커피를 잘 만들어요. '
            '각자 잘하는 걸 만들어 바꾸면 둘 다 이득이에요.',
      ),
      TopicSection(
        emoji: '💡',
        title: '이게 비교우위',
        body: '내가 상대적으로 더 잘하는 일에 집중하는 것이 비교우위예요.',
      ),
    ],
    callout: '공부도 마찬가지! 내가 잘하는 걸 살리면 더 멀리 갈 수 있어요.',
  ),
  EconomyTopic(
    id: 'tariff',
    emoji: '🛃',
    title: '관세가 뭐야?',
    summary: '외국 물건에 붙는 세금',
    sections: [
      TopicSection(
        emoji: '💰',
        title: '수입 물건에 매기는 세금',
        body: '외국에서 들어오는 물건에 붙이는 세금이 관세예요. 그만큼 값이 비싸져요.',
      ),
      TopicSection(
        emoji: '🛡️',
        title: '왜 매길까?',
        body: '우리나라 회사가 값싼 외국 물건에 밀리지 않도록 보호하려고요. '
            '나라 살림에 쓸 돈도 걷을 수 있고요.',
      ),
      TopicSection(
        emoji: '⚠️',
        title: '너무 높으면 손해예요',
        body: '관세가 너무 높으면 소비자가 비싸게 사야 하고, 상대 나라도 똑같이 매겨 '
            '무역 전쟁이 나기도 해요.',
      ),
    ],
    callout: '뉴스에서 관세 인상 이야기가 나오면 물건값이 오를 수 있다는 뜻이에요.',
  ),
  EconomyTopic(
    id: 'company_types',
    emoji: '🏢',
    title: '회사의 종류',
    summary: '주식회사는 왜 생겼을까',
    sections: [
      TopicSection(
        emoji: '🧑‍🍳',
        title: '개인 사업',
        body: '한 사람이 자기 돈으로 차린 가게예요. 결정이 빠르지만 큰돈을 모으긴 어려워요.',
      ),
      TopicSection(
        emoji: '🍕',
        title: '주식회사 — 여럿이 나눠 갖는 회사',
        body: '회사를 잘게 나눈 조각(주식)을 여러 사람에게 팔아 큰돈을 모아요. '
            '그래서 배나 반도체 공장처럼 큰 사업도 할 수 있어요.',
      ),
      TopicSection(
        emoji: '🛟',
        title: '위험도 나눠요',
        body: '회사가 잘못돼도 주주는 자기가 낸 돈까지만 손해를 봐요.',
      ),
    ],
    callout: '주식을 산다는 건 그 회사의 아주 작은 주인이 된다는 뜻이에요.',
  ),
  EconomyTopic(
    id: 'ipo',
    emoji: '🔔',
    title: '상장이 뭐야?',
    summary: '회사가 주식시장에 오르는 것',
    sections: [
      TopicSection(
        emoji: '🚪',
        title: '누구나 살 수 있게 되는 것',
        body: '회사 주식을 주식시장에서 아무나 사고팔 수 있게 되는 걸 상장이라고 해요.',
      ),
      TopicSection(
        emoji: '💵',
        title: '회사는 큰돈을 모아요',
        body: '상장하면서 새 주식을 팔아 공장을 짓거나 연구할 큰돈을 마련할 수 있어요.',
      ),
      TopicSection(
        emoji: '📋',
        title: '대신 규칙을 지켜야 해요',
        body: '상장 회사는 실적을 정기적으로 공개해야 해요. 많은 사람의 돈이 걸려 있으니까요.',
      ),
    ],
    callout: '코스피·코스닥에 있는 회사들이 모두 상장 회사예요.',
  ),
  EconomyTopic(
    id: 'market_cap',
    emoji: '📐',
    title: '시가총액',
    summary: '회사의 크기를 재는 법',
    sections: [
      TopicSection(
        emoji: '✖️',
        title: '주가 × 주식 수',
        body: '주식 1주 값에 전체 주식 수를 곱하면 시가총액이에요. '
            '이 회사를 통째로 사려면 얼마인지에 해당해요.',
      ),
      TopicSection(
        emoji: '🔍',
        title: '주가만 보면 안 돼요',
        body: '1주에 100만 원인 회사가 1주에 1만 원인 회사보다 꼭 크진 않아요. '
            '주식 수가 다르니까요.',
      ),
      TopicSection(
        emoji: '🏆',
        title: '지수와 연결돼요',
        body: '코스피는 상장 회사들의 시가총액을 모아 만든 숫자예요. '
            '큰 회사가 오르면 지수도 많이 움직여요.',
      ),
    ],
    callout: '회사 크기를 물어보면 주가가 아니라 시가총액을 확인하세요!',
  ),
  EconomyTopic(
    id: 'etf',
    emoji: '🧺',
    title: 'ETF가 뭐야?',
    summary: '여러 회사를 한 번에 담는 바구니',
    sections: [
      TopicSection(
        emoji: '🛒',
        title: '주식 여러 개를 묶은 상품',
        body: '수십~수백 개 회사 주식을 한 바구니에 담아 만든 상품이 ETF예요. '
            '한 주만 사도 여러 회사에 나눠 투자한 셈이 돼요.',
      ),
      TopicSection(
        emoji: '🛡️',
        title: '위험이 줄어요',
        body: '한 회사가 망해도 바구니 안 다른 회사들이 버텨줘요.',
      ),
      TopicSection(
        emoji: '🌍',
        title: '지수를 따라가요',
        body: '코스피나 나스닥 같은 지수를 그대로 따라가는 ETF가 많아요.',
      ),
    ],
    callout: '모의 투자에서 지수에 투자하는 것도 ETF를 사는 것과 비슷한 원리예요.',
  ),
  EconomyTopic(
    id: 'bond',
    emoji: '📜',
    title: '채권이 뭐야?',
    summary: '돈을 빌려주고 받는 증서',
    sections: [
      TopicSection(
        emoji: '🤝',
        title: '빌려줬다는 증서',
        body: '나라나 회사가 돈을 빌리면서 언제까지 이자와 함께 갚겠다고 '
            '써주는 증서가 채권이에요.',
      ),
      TopicSection(
        emoji: '🛡️',
        title: '주식보다 안전해요',
        body: '주식은 회사가 잘돼야 이득이지만, 채권은 약속한 이자를 받아요. '
            '대신 크게 벌긴 어려워요.',
      ),
      TopicSection(
        emoji: '⚠️',
        title: '위험이 아예 없진 않아요',
        body: '빌린 곳이 망하면 못 받을 수도 있어요. 그래서 튼튼한 곳의 채권일수록 이자가 낮아요.',
      ),
    ],
    callout: '주식은 주인이 되는 것, 채권은 빌려주는 것이에요.',
  ),
  EconomyTopic(
    id: 'risk_return',
    emoji: '🎲',
    title: '위험과 수익',
    summary: '많이 벌려면 많이 걸어야 해요',
    sections: [
      TopicSection(
        emoji: '📊',
        title: '둘은 짝꿍이에요',
        body: '많이 벌 수 있는 것은 그만큼 잃을 위험도 커요. '
            '안전한 것은 적게 벌어요. 예금이 안전하고 이자가 낮은 이유죠.',
      ),
      TopicSection(
        emoji: '🚨',
        title: '안전한데 많이 번다는 건 거짓말',
        body: '위험 없이 큰돈을 준다는 건 대부분 사기예요. 이 원리를 알면 속지 않아요.',
      ),
      TopicSection(
        emoji: '🧭',
        title: '내가 견딜 수 있는 만큼',
        body: '잃어도 생활이 흔들리지 않는 돈으로만 위험한 투자를 해야 해요.',
      ),
    ],
    callout: '고수익 보장이라는 말을 들으면 일단 의심하세요!',
  ),
  EconomyTopic(
    id: 'dollar_cost',
    emoji: '📅',
    title: '나눠서 사기',
    summary: '적립식 투자의 힘',
    sections: [
      TopicSection(
        emoji: '⏰',
        title: '언제 살지 맞히기는 어려워요',
        body: '전문가도 값이 언제 오르내릴지 정확히 알 수 없어요. '
            '한 번에 다 넣으면 하필 비쌀 때 살 수도 있죠.',
      ),
      TopicSection(
        emoji: '🧊',
        title: '조금씩 여러 번',
        body: '매달 같은 금액씩 나눠 사면 비쌀 때는 조금, 쌀 때는 많이 사게 돼요. '
            '평균 가격이 저절로 낮아져요.',
      ),
      TopicSection(
        emoji: '🧘',
        title: '마음도 편해요',
        body: '값이 떨어져도 다음엔 더 싸게 살 수 있다고 생각하며 견딜 수 있어요.',
      ),
    ],
    callout: '용돈처럼 매주 조금씩 꾸준히 — 투자에서도 통하는 방법이에요.',
  ),
  EconomyTopic(
    id: 'bubble',
    emoji: '🫧',
    title: '거품(버블)',
    summary: '값이 진짜 가치보다 부풀 때',
    sections: [
      TopicSection(
        emoji: '🌷',
        title: '튤립 한 송이가 집 한 채',
        body: '400년 전 네덜란드에서 튤립 뿌리 하나가 집값만큼 비싸진 적이 있어요. '
            '결국 값이 폭락해 많은 사람이 큰돈을 잃었죠.',
      ),
      TopicSection(
        emoji: '🔥',
        title: '남들이 사니까 나도',
        body: '가치보다 남들이 사니까 값이 오르면 거품이에요. 거품은 언젠가 반드시 터져요.',
      ),
      TopicSection(
        emoji: '🧠',
        title: '스스로 판단하기',
        body: '이게 정말 그만한 값어치가 있나 물어보는 습관이 거품에서 나를 지켜줘요.',
      ),
    ],
    callout: '모두가 흥분해 있을 때가 가장 위험한 때예요.',
  ),
  EconomyTopic(
    id: 'insurance',
    emoji: '☂️',
    title: '보험이 뭐야?',
    summary: '여럿이 조금씩 모아 큰일에 대비',
    sections: [
      TopicSection(
        emoji: '👥',
        title: '함께 대비하는 것',
        body: '많은 사람이 조금씩 돈을 모아두었다가, 누군가에게 사고가 나면 '
            '그 돈으로 도와주는 제도예요.',
      ),
      TopicSection(
        emoji: '🏥',
        title: '예상 못한 일에 대비',
        body: '병원비, 자동차 사고, 화재처럼 갑자기 큰돈이 필요한 일에 대비해요.',
      ),
      TopicSection(
        emoji: '💡',
        title: '저축과는 달라요',
        body: '저축은 내 돈이 쌓이는 것, 보험은 사고에 대비해 위험을 나누는 것이에요.',
      ),
    ],
    callout: '비상금과 보험 — 둘 다 혹시 모를 일에 대한 준비예요.',
  ),
  EconomyTopic(
    id: 'pension',
    emoji: '👵',
    title: '연금이 뭐야?',
    summary: '나이 들어 받는 월급',
    sections: [
      TopicSection(
        emoji: '💼',
        title: '일할 때 미리 모아둬요',
        body: '일하는 동안 매달 조금씩 내면, 나이 들어 일을 그만둔 뒤 매달 받아요.',
      ),
      TopicSection(
        emoji: '⏳',
        title: '아주 긴 저축',
        body: '수십 년 동안 모으고 불려서 받는 거라, 복리의 힘이 가장 크게 작용해요.',
      ),
      TopicSection(
        emoji: '🌱',
        title: '일찍 시작할수록 좋아요',
        body: '20대에 시작한 사람과 40대에 시작한 사람의 차이는 상상보다 훨씬 커요.',
      ),
    ],
    callout: '지금 저축 습관을 들이는 게 평생 큰 자산이 될 거예요.',
  ),
  EconomyTopic(
    id: 'public_goods',
    emoji: '🏞️',
    title: '공공재',
    summary: '모두가 함께 쓰는 것',
    sections: [
      TopicSection(
        emoji: '🛣️',
        title: '누구나 쓸 수 있어요',
        body: '도로, 공원, 등대처럼 돈을 안 낸 사람도 쓸 수 있고 '
            '여럿이 써도 줄어들지 않는 것을 공공재라고 해요.',
      ),
      TopicSection(
        emoji: '🤔',
        title: '회사가 만들기 어려워요',
        body: '돈을 안 내도 쓸 수 있으니 아무도 돈을 안 내려 해요. '
            '그래서 회사가 만들어 팔기 어려워요.',
      ),
      TopicSection(
        emoji: '🏛️',
        title: '그래서 나라가 만들어요',
        body: '세금을 걷어 나라가 대신 만들어요. 세금이 필요한 큰 이유 중 하나예요.',
      ),
    ],
    callout: '내가 걷는 길, 노는 공원 모두 우리가 낸 세금으로 만든 거예요.',
  ),
  EconomyTopic(
    id: 'externality',
    emoji: '🏭',
    title: '남에게 주는 영향',
    summary: '외부효과 — 값에 안 들어간 비용',
    sections: [
      TopicSection(
        emoji: '💨',
        title: '공장 매연은 누가 갚나요?',
        body: '공장이 물건을 싸게 만들어도 매연으로 마을 사람들이 피해를 봐요. '
            '이 피해는 물건값에 안 들어가 있어요.',
      ),
      TopicSection(
        emoji: '🌳',
        title: '좋은 영향도 있어요',
        body: '집 앞에 나무를 심으면 지나가는 사람도 좋아요. '
            '이렇게 남에게 이득을 주는 것도 외부효과예요.',
      ),
      TopicSection(
        emoji: '⚖️',
        title: '규칙으로 바로잡아요',
        body: '나라가 오염에 세금을 매기거나 좋은 일에 지원금을 줘서 균형을 맞춰요.',
      ),
    ],
    callout: '내 선택이 남에게 어떤 영향을 주는지 생각하는 것도 경제 공부예요.',
  ),
  EconomyTopic(
    id: 'labor',
    emoji: '👷',
    title: '노동과 임금',
    summary: '왜 직업마다 돈이 다를까',
    sections: [
      TopicSection(
        emoji: '📚',
        title: '기술과 경험이 쌓이면',
        body: '오래 배우고 익혀야 하는 일일수록, 할 수 있는 사람이 적어서 '
            '임금이 높은 경우가 많아요.',
      ),
      TopicSection(
        emoji: '⚖️',
        title: '여기도 수요와 공급',
        body: '그 일을 하려는 사람이 적고 필요로 하는 곳은 많으면 임금이 올라가요.',
      ),
      TopicSection(
        emoji: '🛡️',
        title: '최저임금',
        body: '너무 적게 주지 못하도록 나라가 정한 최소한의 시급이 최저임금이에요.',
      ),
    ],
    callout: '나에게 맞는 일을 찾고 실력을 키우는 게 최고의 투자예요.',
  ),
  EconomyTopic(
    id: 'entrepreneur',
    emoji: '🚀',
    title: '창업과 기업가정신',
    summary: '없던 것을 만들어내는 힘',
    sections: [
      TopicSection(
        emoji: '💡',
        title: '불편함에서 시작해요',
        body: '이게 있으면 좋겠는데 하는 생각에서 새로운 사업이 태어나요.',
      ),
      TopicSection(
        emoji: '🎲',
        title: '위험을 감수해요',
        body: '성공할지 모르는 일에 시간과 돈을 거는 용기가 필요해요. '
            '실패도 많지만 그만큼 배워요.',
      ),
      TopicSection(
        emoji: '🌍',
        title: '세상을 바꿔요',
        body: '스마트폰, 인터넷 쇼핑 모두 누군가의 도전에서 시작됐어요.',
      ),
    ],
    callout: '실패를 배움으로 바꾸는 사람이 결국 크게 성공해요.',
  ),
  EconomyTopic(
    id: 'gov_budget',
    emoji: '📋',
    title: '나라의 살림',
    summary: '예산과 나랏빚',
    sections: [
      TopicSection(
        emoji: '💰',
        title: '들어오는 돈과 나가는 돈',
        body: '나라도 세금으로 돈을 걷고, 학교·도로·복지에 써요. 이 계획이 예산이에요.',
      ),
      TopicSection(
        emoji: '📉',
        title: '모자라면 빚을 져요',
        body: '쓸 곳이 걷은 돈보다 많으면 나라도 채권을 팔아 빌려요. 이게 나랏빚이에요.',
      ),
      TopicSection(
        emoji: '⚠️',
        title: '빚이 너무 많으면',
        body: '이자 갚는 데 돈이 많이 들어 정작 필요한 곳에 못 써요. '
            '나라 살림도 균형이 중요해요.',
      ),
    ],
    callout: '우리 집 용돈 계획과 나라 예산은 원리가 똑같아요!',
  ),
  EconomyTopic(
    id: 'digital_money',
    emoji: '📱',
    title: '보이지 않는 돈',
    summary: '카드·간편결제·전자화폐',
    sections: [
      TopicSection(
        emoji: '💳',
        title: '지폐 없이도 사요',
        body: '카드나 휴대폰으로 결제하면 지폐가 오가지 않아도 은행 계좌 숫자만 바뀌어요.',
      ),
      TopicSection(
        emoji: '🧠',
        title: '쓰는 느낌이 약해져요',
        body: '현금은 줄어드는 게 보이는데 카드는 안 보여서 더 많이 쓰게 되기 쉬워요.',
      ),
      TopicSection(
        emoji: '📒',
        title: '그래서 기록이 중요해요',
        body: '보이지 않는 돈일수록 얼마 썼는지 적어두는 습관이 꼭 필요해요.',
      ),
    ],
    callout: '이 앱에 내역을 적는 것도 그래서예요. 보이게 만들면 관리할 수 있어요!',
  ),
  EconomyTopic(
    id: 'crypto',
    emoji: '🪙',
    title: '가상자산 이야기',
    summary: '비트코인 같은 건 뭘까',
    sections: [
      TopicSection(
        emoji: '💻',
        title: '컴퓨터로 만든 자산',
        body: '나라가 보증하는 돈이 아니라, 컴퓨터 네트워크에서 만들어지고 '
            '거래되는 자산이에요.',
      ),
      TopicSection(
        emoji: '🎢',
        title: '값이 아주 크게 흔들려요',
        body: '하루에 몇십 %씩 오르내리기도 해요. 그만큼 위험이 매우 큽니다.',
      ),
      TopicSection(
        emoji: '🚸',
        title: '어린이는 특히 조심',
        body: '금방 부자 된다는 말에 속아 큰돈을 잃는 사람이 많아요. '
            '어른이 되어 충분히 공부한 뒤에 판단할 일이에요.',
      ),
    ],
    callout: '이해하지 못하는 것에는 투자하지 않는다 — 투자의 첫 번째 원칙이에요.',
  ),
  EconomyTopic(
    id: 'goal_planning',
    emoji: '🗺️',
    title: '돈 계획 세우기',
    summary: '단기·중기·장기 목표',
    sections: [
      TopicSection(
        emoji: '🍫',
        title: '단기 — 몇 주 안',
        body: '간식이나 작은 장난감처럼 금방 살 수 있는 목표예요. 저금통으로 충분해요.',
      ),
      TopicSection(
        emoji: '🚲',
        title: '중기 — 몇 달~1년',
        body: '자전거처럼 몇 달 모아야 하는 목표예요. 예금이나 적금이 어울려요.',
      ),
      TopicSection(
        emoji: '🎓',
        title: '장기 — 몇 년 이상',
        body: '대학 등록금처럼 아주 먼 목표는 투자를 섞으면 물가를 이길 수 있어요.',
      ),
    ],
    callout: '기간에 맞는 방법을 고르는 것 — 이게 돈 계획의 핵심이에요.',
  ),
  EconomyTopic(
    id: 'consumer_rights',
    emoji: '🧾',
    title: '소비자의 권리',
    summary: '잘못 샀을 때 어떻게 할까',
    sections: [
      TopicSection(
        emoji: '↩️',
        title: '반품과 환불',
        body: '인터넷으로 산 물건은 보통 받은 날부터 7일 안에 바꾸거나 돌려받을 수 있어요.',
      ),
      TopicSection(
        emoji: '🧾',
        title: '영수증을 챙겨요',
        body: '영수증은 내가 여기서 이걸 샀다는 증거예요. 문제가 생기면 꼭 필요해요.',
      ),
      TopicSection(
        emoji: '📞',
        title: '도와주는 곳이 있어요',
        body: '가게와 해결이 안 되면 소비자원 같은 기관에 도움을 요청할 수 있어요.',
      ),
    ],
    callout: '소비자에게도 권리가 있어요. 알고 있으면 당당하게 요구할 수 있어요.',
  ),
  EconomyTopic(
    id: 'ai_economy',
    emoji: '🤖',
    title: '기술이 바꾸는 경제',
    summary: '기계와 AI가 일을 대신하면',
    sections: [
      TopicSection(
        emoji: '🚜',
        title: '늘 있었던 변화예요',
        body: '트랙터가 나오며 농사일이 줄었지만, 대신 새로운 일자리가 많이 생겼어요.',
      ),
      TopicSection(
        emoji: '🔄',
        title: '없어지는 일, 생기는 일',
        body: '단순 반복하는 일은 기계가 대신하고, 사람은 새로 만들고 결정하는 일을 해요.',
      ),
      TopicSection(
        emoji: '📖',
        title: '계속 배우는 힘',
        body: '어떤 기술이 와도 배우고 적응하는 사람은 언제나 자리를 찾아요.',
      ),
    ],
    callout: '변화를 두려워하지 말고 배우는 힘을 키우세요.',
  ),
  // ───────── 생활 밀착 주제 (초등 2~6학년) ─────────
  EconomyTopic(
    id: 'deposit_types',
    emoji: '💰',
    title: '예금과 적금',
    summary: '한 번에 맡기기 vs 매달 넣기',
    sections: [
      TopicSection(
        emoji: '🏦',
        title: '예금 — 한 번에 맡겨두기',
        body: '세뱃돈처럼 큰돈이 한 번에 생겼을 때, 은행에 맡겨두고 정해진 날까지 안 꺼내는 거예요. '
            '오래 맡길수록 이자를 더 줘요.',
      ),
      TopicSection(
        emoji: '📅',
        title: '적금 — 매달 조금씩 넣기',
        body: '용돈처럼 매달 들어오는 돈을 조금씩 모으는 방법이에요. '
            '"매달 5천원씩 1년" 이렇게 약속하고 넣어요.',
      ),
      TopicSection(
        emoji: '🤔',
        title: '뭐가 더 좋을까?',
        body: '큰돈이 이미 있으면 예금, 앞으로 모을 거면 적금이에요. '
            '둘 다 중간에 깨면 약속한 이자를 다 못 받으니 기간을 잘 정해야 해요.',
      ),
    ],
    callout: '이 앱의 저축 이자도 은행 예금 이자를 따라가요. 설정에서 확인해보세요!',
  ),
  EconomyTopic(
    id: 'principal',
    emoji: '🌰',
    title: '원금과 이자',
    summary: '내가 넣은 돈과 늘어난 돈',
    sections: [
      TopicSection(
        emoji: '🌱',
        title: '원금 — 처음 넣은 씨앗',
        body: '내가 직접 모아서 넣은 돈이 원금이에요. 씨앗에 해당해요.',
      ),
      TopicSection(
        emoji: '🌿',
        title: '이자 — 씨앗에서 자란 잎',
        body: '원금을 맡겨둔 대가로 더 받는 돈이 이자예요. '
            '10,000원을 맡겨서 300원이 늘었다면 원금은 10,000원, 이자는 300원이에요.',
      ),
      TopicSection(
        emoji: '⚠️',
        title: '둘을 섞어서 보면 착각해요',
        body: '"10,300원이 됐다"만 보면 얼마를 벌었는지 몰라요. '
            '원금과 이자를 나눠서 봐야 내가 정말 얼마를 얻었는지 알 수 있어요.',
      ),
    ],
    callout: '내역 탭에서 "이자"만 모아 보면 지금까지 받은 이자 총액이 보여요.',
  ),
  EconomyTopic(
    id: 'card_types',
    emoji: '💳',
    title: '신용카드와 체크카드',
    summary: '지금 내는 카드, 나중에 내는 카드',
    sections: [
      TopicSection(
        emoji: '✅',
        title: '체크카드 — 통장에 있는 만큼만',
        body: '통장에 든 돈에서 바로 빠져나가요. 돈이 없으면 결제가 안 돼서 과소비를 막아줘요.',
      ),
      TopicSection(
        emoji: '📄',
        title: '신용카드 — 먼저 쓰고 나중에 갚기',
        body: '카드회사가 대신 내주고, 다음 달에 내가 갚아요. '
            '지금 돈이 없어도 살 수 있으니 편하지만 그만큼 위험해요.',
      ),
      TopicSection(
        emoji: '🚨',
        title: '왜 위험할까',
        body: '내 돈이 줄어드는 게 눈에 안 보여서 얼마 썼는지 잊어버려요. '
            '못 갚으면 이자를 더 내야 하고, 신용도 나빠져요.',
      ),
    ],
    callout: '어른이 되면 체크카드부터 쓰는 게 안전해요. 쓴 만큼만 나가니까요.',
  ),
  EconomyTopic(
    id: 'unit_price',
    emoji: '⚖️',
    title: '단위당 가격으로 비교하기',
    summary: '큰 게 꼭 싼 건 아니에요',
    sections: [
      TopicSection(
        emoji: '🥤',
        title: '값만 보면 속아요',
        body: '작은 우유 1,000원, 큰 우유 1,800원. 큰 게 비싸 보이지만 양이 두 배면 큰 게 싼 거예요.',
      ),
      TopicSection(
        emoji: '🧮',
        title: '1개(또는 100g)당 얼마인지 계산해요',
        body: '값을 개수나 무게로 나눠보세요. 과자 6개 3,000원이면 1개 500원, '
            '10개 4,000원이면 1개 400원이에요. 뒤쪽이 더 싸요.',
      ),
      TopicSection(
        emoji: '🏷️',
        title: '가격표에 이미 적혀 있어요',
        body: '마트 가격표를 잘 보면 작은 글씨로 "100g당 ○○원"이 적혀 있어요. '
            '그것만 비교하면 금방 알 수 있어요.',
      ),
    ],
    callout: '다음에 마트 가면 같은 물건 두 개의 100g당 가격을 비교해보세요!',
  ),
  EconomyTopic(
    id: 'discount_trap',
    emoji: '🏷️',
    title: '할인의 함정',
    summary: '싸게 샀는데 왜 돈이 없지?',
    sections: [
      TopicSection(
        emoji: '💭',
        title: '"싸다"는 사고 싶게 만드는 말',
        body: '50% 할인이라고 하면 안 사면 손해 같아요. '
            '하지만 원래 필요 없던 물건이면 반값이라도 그냥 돈을 쓴 거예요.',
      ),
      TopicSection(
        emoji: '➕',
        title: '"하나 더" 함정',
        body: '1+1은 두 개가 다 필요할 때만 이득이에요. '
            '혼자 다 못 먹고 버리면 오히려 손해예요.',
      ),
      TopicSection(
        emoji: '🎯',
        title: '판단 기준은 하나',
        body: '"할인이 아니었어도 이걸 살까?" 답이 아니라면 안 사는 게 아끼는 거예요.',
      ),
    ],
    callout: '아낀 돈은 쓴 게 아니라 남은 돈이어야 해요. 통장에 남았는지 확인해보세요!',
  ),
  EconomyTopic(
    id: 'subscription',
    emoji: '📅',
    title: '구독 서비스',
    summary: '매달 조금씩 빠져나가는 돈',
    sections: [
      TopicSection(
        emoji: '🎬',
        title: '한 번 신청하면 매달 나가요',
        body: '유튜브 프리미엄, 게임 이용권처럼 매달 자동으로 돈이 빠져나가는 서비스예요. '
            '한 번만 누르면 그다음엔 신경 안 써도 계속 나가요.',
      ),
      TopicSection(
        emoji: '🧮',
        title: '작아 보이지만 1년이면 커요',
        body: '한 달에 5,000원이면 1년에 60,000원이에요. '
            '두 개, 세 개 쌓이면 용돈이 통째로 사라져요.',
      ),
      TopicSection(
        emoji: '🔍',
        title: '안 쓰는 건 끊어요',
        body: '한 달에 한 번은 "내가 지금 뭘 구독 중인지" 확인하세요. '
            '요즘 안 본다면 끊고, 필요할 때 다시 신청하면 돼요.',
      ),
    ],
    callout: '무료 체험도 기간이 지나면 돈이 나가요. 신청할 때 언제부터 돈이 나가는지 꼭 확인!',
  ),
  EconomyTopic(
    id: 'game_items',
    emoji: '🎮',
    title: '게임 아이템과 확률',
    summary: '뽑기에 쓰는 돈 생각해보기',
    sections: [
      TopicSection(
        emoji: '🎲',
        title: '뽑기는 확률이에요',
        body: '"1% 확률"은 100번 뽑으면 한 번 나온다는 뜻이 아니에요. '
            '100번 뽑아도 안 나올 수 있어요. 운이지 실력이 아니에요.',
      ),
      TopicSection(
        emoji: '💸',
        title: '조금씩이라 더 무서워요',
        body: '한 번에 1,000원이면 별것 아닌 것 같지만, 열 번이면 10,000원이에요. '
            '게임 안에서는 얼마 썼는지 세기가 어려워요.',
      ),
      TopicSection(
        emoji: '🤔',
        title: '사기 전에 물어볼 것',
        body: '"이걸 사면 게임 밖에서도 남는 게 있을까?" '
            '아이템은 게임이 끝나면 사라져요. 그래도 좋다면, 미리 정한 금액 안에서만 쓰세요.',
      ),
    ],
    callout: '갖고 싶은 아이템이 있으면 위시리스트에 올려보세요. 며칠 뒤에도 갖고 싶은지 보면 알아요.',
  ),
  EconomyTopic(
    id: 'ad_economy',
    emoji: '📺',
    title: '공짜 앱은 왜 공짜일까',
    summary: '광고가 대신 돈을 내요',
    sections: [
      TopicSection(
        emoji: '🆓',
        title: '진짜 공짜는 드물어요',
        body: '앱을 만들고 서버를 돌리는 데는 돈이 들어요. '
            '내가 돈을 안 냈다면 누군가 대신 낸 거예요.',
      ),
      TopicSection(
        emoji: '📢',
        title: '광고주가 돈을 내요',
        body: '회사들이 "우리 물건 보여주세요" 하고 앱에 돈을 내요. '
            '내가 광고를 보는 것이 앱을 쓰는 값이에요.',
      ),
      TopicSection(
        emoji: '👀',
        title: '그래서 광고는 잘 만들어요',
        body: '광고는 사고 싶게 만드는 게 목적이에요. '
            '재미있게 보는 건 좋지만, 광고를 봤다고 꼭 살 필요는 없어요.',
      ),
    ],
    callout: '광고를 보고 뭔가 갖고 싶어지면, 그게 광고가 잘 만들어졌다는 뜻이에요!',
  ),
  EconomyTopic(
    id: 'copyright',
    emoji: '✍️',
    title: '저작권',
    summary: '만든 사람의 몫',
    sections: [
      TopicSection(
        emoji: '🎵',
        title: '만든 것도 재산이에요',
        body: '노래, 그림, 웹툰, 게임은 누군가 오래 애써서 만든 거예요. '
            '눈에 안 보여도 그 사람의 재산이에요.',
      ),
      TopicSection(
        emoji: '🚫',
        title: '몰래 쓰면 안 돼요',
        body: '불법 사이트에서 웹툰을 보거나 파일을 받으면, 만든 사람은 돈을 못 받아요. '
            '그러면 다음 작품을 만들기 어려워져요.',
      ),
      TopicSection(
        emoji: '👍',
        title: '값을 내면 계속 볼 수 있어요',
        body: '정식으로 돈을 내고 보는 게 응원이에요. '
            '내가 낸 돈이 작가에게 가서 다음 편이 나와요.',
      ),
    ],
    callout: '좋아하는 작품이 계속 나오길 바란다면, 제대로 값을 내는 게 가장 확실한 응원이에요.',
  ),
  EconomyTopic(
    id: 'scam',
    emoji: '🚨',
    title: '온라인 사기 조심',
    summary: '공짜와 급함을 의심해요',
    sections: [
      TopicSection(
        emoji: '🎁',
        title: '"공짜로 줄게" 는 의심',
        body: '게임 아이템을 공짜로 준다며 아이디와 비밀번호를 물어보면 100% 사기예요. '
            '진짜 이벤트는 비밀번호를 절대 묻지 않아요.',
      ),
      TopicSection(
        emoji: '⏰',
        title: '"빨리" 를 재촉하면 의심',
        body: '"지금 안 하면 못 받아요" 하고 서두르게 만드는 건 생각할 틈을 안 주려는 거예요. '
            '급하게 굴수록 더 천천히 하세요.',
      ),
      TopicSection(
        emoji: '🙋',
        title: '어른에게 먼저 물어요',
        body: '돈이나 개인정보가 나오는 이야기는 반드시 부모님께 먼저 보여주세요. '
            '혼날까 봐 숨기면 더 큰 피해가 돼요.',
      ),
    ],
    callout: '비밀번호는 가족에게도 문자로 보내지 않아요. 이건 어른도 똑같이 지키는 규칙이에요.',
  ),
  EconomyTopic(
    id: 'refund',
    emoji: '🔄',
    title: '환불과 교환',
    summary: '잘못 샀을 때 어떻게 할까',
    sections: [
      TopicSection(
        emoji: '🧾',
        title: '영수증을 챙겨요',
        body: '언제 어디서 얼마에 샀는지 증거가 영수증이에요. '
            '이게 있으면 바꾸거나 돌려받기가 훨씬 쉬워요.',
      ),
      TopicSection(
        emoji: '📦',
        title: '인터넷으로 산 건 7일',
        body: '인터넷에서 산 물건은 받은 날부터 7일 안에 마음이 바뀌어도 돌려보낼 수 있어요. '
            '단, 뜯어서 쓰거나 망가뜨리면 어려워져요.',
      ),
      TopicSection(
        emoji: '💬',
        title: '정중하게 말하면 통해요',
        body: '"이런 이유로 바꾸고 싶어요" 하고 차분히 말하는 게 가장 빨라요. '
            '화를 내는 것보다 이유를 또박또박 말하는 게 힘이 세요.',
      ),
    ],
    callout: '중요한 물건을 살 때는 "바꿀 수 있나요?"를 사기 전에 물어보세요.',
  ),
  EconomyTopic(
    id: 'secondhand',
    emoji: '🤝',
    title: '중고거래',
    summary: '쓰던 물건도 값이 있어요',
    sections: [
      TopicSection(
        emoji: '♻️',
        title: '안 쓰는 물건은 돈이 돼요',
        body: '작아진 옷, 다 읽은 책, 안 하는 장난감도 다른 사람에겐 필요할 수 있어요. '
            '버리는 대신 팔면 돈이 되고 쓰레기도 줄어요.',
      ),
      TopicSection(
        emoji: '📉',
        title: '값은 새것보다 싸요',
        body: '30,000원에 산 장난감을 30,000원에 팔 수는 없어요. '
            '쓴 만큼 값이 내려가요. 그래서 살 때 오래 쓸 걸 고르는 게 이득이에요.',
      ),
      TopicSection(
        emoji: '👨‍👩‍👧',
        title: '거래는 어른과 함께',
        body: '모르는 사람을 직접 만나는 일이라 꼭 부모님과 같이 하세요. '
            '돈을 먼저 보내라는 사람은 특히 조심해야 해요.',
      ),
    ],
    callout: '내 방에 안 쓰는 물건이 몇 개 있는지 세어보세요. 생각보다 많을 거예요!',
  ),
  EconomyTopic(
    id: 'emergency_fund',
    emoji: '🧰',
    title: '비상금',
    summary: '갑자기 필요할 때를 위한 돈',
    sections: [
      TopicSection(
        emoji: '😮',
        title: '갑자기 돈이 필요할 때가 있어요',
        body: '준비물을 잃어버렸거나, 친구 생일을 깜빡했을 때처럼 예상 못 한 일이 생겨요.',
      ),
      TopicSection(
        emoji: '🔒',
        title: '따로 떼어 손대지 않아요',
        body: '비상금은 목표 저축과 따로 두고, 정말 급할 때만 써요. '
            '평소에 조금씩 꺼내 쓰면 비상금이 아니에요.',
      ),
      TopicSection(
        emoji: '🔁',
        title: '쓰면 다시 채워요',
        body: '비상금을 썼다면 다음 용돈에서 먼저 채워두세요. '
            '그래야 다음 비상 상황에도 버틸 수 있어요.',
      ),
    ],
    callout: '어른들은 3~6개월치 생활비를 비상금으로 둬요. 아주 중요한 습관이에요!',
  ),
  EconomyTopic(
    id: 'lending_friends',
    emoji: '🫂',
    title: '친구와 돈',
    summary: '빌려주기 전에 생각할 것',
    sections: [
      TopicSection(
        emoji: '💵',
        title: '빌려주면 못 받을 수도 있어요',
        body: '친구가 일부러 안 갚는 게 아니라 그냥 잊어버리기도 해요. '
            '돌려받지 못해도 괜찮은 만큼만 빌려주세요.',
      ),
      TopicSection(
        emoji: '📝',
        title: '언제 갚을지 정해요',
        body: '"다음 주 월요일에 갚기"처럼 날짜를 정하면 서로 편해요. '
            '말로만 하지 않고 적어두면 더 좋아요.',
      ),
      TopicSection(
        emoji: '💔',
        title: '돈 때문에 친구를 잃지 않기',
        body: '큰돈이 오가면 사이가 어색해져요. '
            '정말 도와주고 싶다면 빌려주기보다 그냥 주는 게 나을 때도 있어요.',
      ),
    ],
    callout: '친구가 자꾸 돈을 빌려달라고 하면 부모님께 이야기하세요. 혼자 판단할 일이 아니에요.',
  ),
  EconomyTopic(
    id: 'new_year_money',
    emoji: '🧧',
    title: '세뱃돈 관리하기',
    summary: '한 번에 큰돈이 들어올 때',
    sections: [
      TopicSection(
        emoji: '🎊',
        title: '큰돈은 사라지기도 쉬워요',
        body: '평소보다 훨씬 많은 돈이 한 번에 들어오면 "이 정도는 써도 되겠지" 싶어져요. '
            '그렇게 며칠이면 다 없어져요.',
      ),
      TopicSection(
        emoji: '➗',
        title: '먼저 나눠놓아요',
        body: '받은 즉시 "모을 돈 / 쓸 돈 / 나눌 돈"으로 나눠보세요. '
            '예를 들어 7 대 2 대 1처럼 비율을 미리 정해두면 쉬워요.',
      ),
      TopicSection(
        emoji: '🏦',
        title: '모을 돈은 눈에 안 보이게',
        body: '지갑에 있으면 쓰게 돼요. 모을 몫은 통장이나 저축에 바로 넣어두세요.',
      ),
    ],
    callout: '세뱃돈이 들어오면 이 앱에 "특별 수입"으로 기록하고 누가 줬는지도 남겨보세요!',
  ),
  EconomyTopic(
    id: 'dividend',
    emoji: '🎁',
    title: '배당금',
    summary: '주식이 나눠주는 선물',
    sections: [
      TopicSection(
        emoji: '🍕',
        title: '회사가 번 돈을 나눠줘요',
        body: '주식은 회사의 조각이에요. 회사가 돈을 잘 벌면 그중 일부를 주인들에게 나눠줘요. '
            '그게 배당금이에요.',
      ),
      TopicSection(
        emoji: '🌳',
        title: '팔지 않아도 생기는 돈',
        body: '주식을 팔아서 버는 것과 달리, 배당금은 갖고만 있어도 들어와요. '
            '나무를 안 베고 열매만 따는 것과 비슷해요.',
      ),
      TopicSection(
        emoji: '⚠️',
        title: '항상 주는 건 아니에요',
        body: '회사가 어려우면 배당을 줄이거나 안 줄 수도 있어요. '
            '빠르게 커지는 회사는 나눠주는 대신 다시 회사에 쓰기도 해요.',
      ),
    ],
    callout: '배당금을 다시 주식 사는 데 쓰면 복리처럼 눈덩이가 커져요!',
  ),
  EconomyTopic(
    id: 'barter',
    emoji: '🐚',
    title: '물물교환에서 돈까지',
    summary: '돈이 없던 시절 이야기',
    sections: [
      TopicSection(
        emoji: '🔄',
        title: '옛날엔 물건끼리 바꿨어요',
        body: '쌀이 남는 사람과 생선이 남는 사람이 서로 바꿨어요. 이게 물물교환이에요.',
      ),
      TopicSection(
        emoji: '😵',
        title: '그런데 너무 불편했어요',
        body: '내가 원하는 걸 가진 사람이 마침 내 물건도 원해야 거래가 돼요. '
            '게다가 생선은 며칠이면 상해버려요.',
      ),
      TopicSection(
        emoji: '🪙',
        title: '그래서 돈이 생겼어요',
        body: '조개껍데기, 소금, 쇠붙이처럼 누구나 받아주고 잘 안 상하는 걸 돈으로 썼어요. '
            '나중엔 금속 동전과 종이돈이 됐고, 지금은 눈에 안 보이는 숫자가 됐어요.',
      ),
    ],
    callout: '돈은 물건이 아니라 "약속"이에요. 모두가 값이 있다고 믿어서 값이 생겨요.',
  ),
  EconomyTopic(
    id: 'jobs',
    emoji: '🧑‍🌾',
    title: '돈을 버는 여러 방법',
    summary: '일해서 벌기, 만들어서 벌기',
    sections: [
      TopicSection(
        emoji: '⏰',
        title: '시간을 써서 벌기',
        body: '회사에 다니거나 가게에서 일하면 일한 시간만큼 돈을 받아요. '
            '가장 확실하지만 하루는 24시간뿐이라 한계가 있어요.',
      ),
      TopicSection(
        emoji: '🛠️',
        title: '만들어서 벌기',
        body: '가게를 열거나 물건을 만들어 팔면, 잘되면 훨씬 많이 벌어요. '
            '대신 안 될 수도 있어서 위험이 따라와요.',
      ),
      TopicSection(
        emoji: '🌱',
        title: '돈이 일하게 하기',
        body: '모아둔 돈을 저축하거나 투자하면 내가 자는 동안에도 이자와 수익이 생겨요. '
            '그래서 어릴 때부터 모으는 습관이 힘이 돼요.',
      ),
    ],
    callout: '어른들은 이 세 가지를 섞어서 살아요. 어떤 방법이 제일 재미있어 보이나요?',
  ),
  EconomyTopic(
    id: 'negotiation',
    emoji: '🗣️',
    title: '용돈 협상하기',
    summary: '이유를 준비하면 통해요',
    sections: [
      TopicSection(
        emoji: '📊',
        title: '기록이 가장 센 무기예요',
        body: '"용돈 올려주세요"보다 "지난 3달 동안 이렇게 썼고 이만큼 모았어요"가 훨씬 힘이 세요. '
            '내역이 있으면 믿어줘요.',
      ),
      TopicSection(
        emoji: '🎯',
        title: '왜 필요한지 말해요',
        body: '무엇에 쓸 건지, 얼마가 왜 더 필요한지 구체적으로 말하세요. '
            '"그냥"은 설득이 안 돼요.',
      ),
      TopicSection(
        emoji: '🤝',
        title: '주고받는 거예요',
        body: '"집안일을 더 하겠다"처럼 내가 할 것도 함께 내놓으면 협상이 잘돼요. '
            '한쪽만 얻는 건 협상이 아니에요.',
      ),
    ],
    callout: '이 앱의 통계 화면을 부모님께 보여드리는 게 가장 좋은 협상 자료예요!',
  ),
  EconomyTopic(
    id: 'econ_news',
    emoji: '📰',
    title: '경제 뉴스 읽기',
    summary: '어려운 말 뜻만 알면 재미있어요',
    sections: [
      TopicSection(
        emoji: '🔤',
        title: '자주 나오는 말은 몇 개뿐',
        body: '금리, 물가, 환율, 주가. 뉴스에 나오는 경제 이야기는 대부분 이 네 가지 이야기예요. '
            '이미 다 배운 것들이죠!',
      ),
      TopicSection(
        emoji: '📈',
        title: '"올랐다·내렸다"만 봐도 돼요',
        body: '숫자를 다 이해할 필요 없어요. 무엇이 올랐고 내렸는지, '
            '그러면 우리 집에 어떤 영향이 있는지만 생각해보세요.',
      ),
      TopicSection(
        emoji: '🤨',
        title: '한 사람 말만 믿지 않아요',
        body: '"주가가 오를 것"이라고 단정하는 사람은 조심해야 해요. '
            '앞일은 아무도 정확히 몰라요.',
      ),
    ],
    callout: '홈 화면의 금리·지수를 매주 한 번씩 보면 뉴스가 훨씬 잘 들려요!',
  ),

  // ─────────────────────────────────────────────────────────────
  // 5차 추가분 — 경제의 기본 뼈대(희소성·경제주체·시장)와, 아이가 실제로
  // 마주치는 생활 장면(통장·이체·할부·포인트·리뷰 등)을 채웠다.
  // ─────────────────────────────────────────────────────────────

  EconomyTopic(
    id: 'scarcity',
    emoji: '🍰',
    title: '희소성이 뭐야?',
    summary: '갖고 싶은 건 많은데 돈은 정해져 있어요',
    sections: [
      TopicSection(
        emoji: '🙋',
        title: '원하는 건 끝이 없어요',
        body: '갖고 싶은 걸 적어보면 계속 나와요. 그런데 용돈은 정해져 있죠? '
            '이렇게 원하는 것보다 가진 게 적은 상태를 희소하다고 해요.',
      ),
      TopicSection(
        emoji: '⚖️',
        title: '그래서 고르게 돼요',
        body: '돈이 무한하면 고민할 필요가 없어요. 정해져 있으니까 뭘 먼저 살지 정하게 되죠. '
            '경제 공부는 사실 이 고르는 법을 배우는 거예요.',
      ),
      TopicSection(
        emoji: '⏰',
        title: '시간도 희소해요',
        body: '하루는 24시간뿐이에요. 게임을 하면 그만큼 책 읽을 시간이 줄죠. '
            '돈뿐 아니라 시간도 잘 나눠 써야 해요.',
      ),
    ],
    callout: '희소성은 모든 경제 이야기의 출발점이에요. 그래서 기회비용이 생겨요!',
  ),
  EconomyTopic(
    id: 'economic_agents',
    emoji: '🔄',
    title: '경제는 누가 움직일까',
    summary: '가계·기업·정부가 서로 주고받아요',
    sections: [
      TopicSection(
        emoji: '🏠',
        title: '가계 — 우리 집',
        body: '어른들은 일하고 돈을 벌어요. 그 돈으로 물건을 사죠. '
            '우리 집처럼 쓰는 쪽을 가계라고 해요.',
      ),
      TopicSection(
        emoji: '🏭',
        title: '기업 — 만들어 파는 곳',
        body: '회사는 물건과 서비스를 만들어 팔아요. 일할 사람을 뽑고 월급을 주죠. '
            '가계가 낸 돈이 기업으로 가요.',
      ),
      TopicSection(
        emoji: '🏛️',
        title: '정부 — 규칙을 만들고 나눠 쓰는 곳',
        body: '정부는 세금을 걷어 학교·도로·병원을 만들어요. '
            '가계와 기업이 잘 지내도록 규칙도 정하고요.',
      ),
    ],
    callout: '돈이 셋 사이를 빙글빙글 돌아요. 이게 경제가 굴러가는 모습이에요!',
  ),
  EconomyTopic(
    id: 'market',
    emoji: '🏪',
    title: '시장이 뭐야?',
    summary: '사는 사람과 파는 사람이 만나는 곳',
    sections: [
      TopicSection(
        emoji: '🥕',
        title: '꼭 건물이 아니어도 돼요',
        body: '전통시장도 시장이지만, 온라인 쇼핑몰도 시장이에요. '
            '사고파는 일이 일어나는 곳이면 다 시장이라고 불러요.',
      ),
      TopicSection(
        emoji: '🤝',
        title: '둘 다 이득이라 거래해요',
        body: '파는 사람은 돈이 필요하고, 사는 사람은 물건이 필요해요. '
            '서로 원하는 걸 얻으니까 거래가 이뤄져요.',
      ),
      TopicSection(
        emoji: '💹',
        title: '주식시장도 시장이에요',
        body: '회사 조각(주식)을 사고파는 시장도 있어요. '
            '코스피는 그 시장의 성적표예요.',
      ),
    ],
    callout: '시장에서 값이 정해지는 방법이 바로 수요와 공급이에요!',
  ),
  EconomyTopic(
    id: 'division_labor',
    emoji: '🧩',
    title: '나눠서 하면 빨라요',
    summary: '각자 한 가지씩 맡는 분업',
    sections: [
      TopicSection(
        emoji: '🍕',
        title: '혼자 다 하면 느려요',
        body: '피자 가게에서 한 사람이 반죽하고 굽고 배달까지 하면 오래 걸려요. '
            '나눠 맡으면 훨씬 빨라지죠.',
      ),
      TopicSection(
        emoji: '🎯',
        title: '잘하게 되고 빨라져요',
        body: '같은 일을 계속하면 손에 익어요. 그래서 분업하면 더 많이, 더 좋게 만들 수 있어요.',
      ),
      TopicSection(
        emoji: '🌍',
        title: '나라끼리도 나눠 맡아요',
        body: '한 나라가 모든 걸 만들지 않아요. 잘하는 걸 만들어 서로 바꾸죠. '
            '그게 무역이에요.',
      ),
    ],
    callout: '연필 한 자루도 수많은 사람이 나눠 만든 거예요!',
  ),
  EconomyTopic(
    id: 'assets_debt',
    emoji: '⚖️',
    title: '자산과 부채',
    summary: '가진 것에서 갚을 것을 빼면 진짜 내 돈',
    sections: [
      TopicSection(
        emoji: '💰',
        title: '자산 — 내가 가진 것',
        body: '저금통 속 돈, 통장 잔액, 주식 같은 게 자산이에요. '
            '돈으로 바꿀 수 있는 것들이죠.',
      ),
      TopicSection(
        emoji: '📄',
        title: '부채 — 갚아야 할 것',
        body: '친구에게 빌린 1,000원은 내 돈처럼 보여도 갚아야 해요. '
            '이렇게 갚을 돈을 부채라고 해요.',
      ),
      TopicSection(
        emoji: '🧮',
        title: '자산 − 부채 = 순자산',
        body: '10,000원이 있어도 3,000원을 빌렸다면 진짜 내 것은 7,000원이에요. '
            '이걸 순자산이라고 해요.',
      ),
    ],
    callout: '앱의 잔액은 빌린 돈이 없다는 가정이에요. 빌린 게 있으면 따로 적어두세요!',
  ),
  EconomyTopic(
    id: 'income_types',
    emoji: '💵',
    title: '소득의 종류',
    summary: '돈이 들어오는 길은 여러 갈래',
    sections: [
      TopicSection(
        emoji: '👷',
        title: '일해서 버는 돈',
        body: '회사에 다니거나 가게에서 일하고 받는 월급이에요. '
            '가장 흔한 소득이죠.',
      ),
      TopicSection(
        emoji: '🏪',
        title: '장사해서 버는 돈',
        body: '가게를 열거나 물건을 만들어 팔아 버는 돈이에요. '
            '많이 벌 수도 있지만 손해를 볼 수도 있어요.',
      ),
      TopicSection(
        emoji: '🌱',
        title: '가진 것이 벌어주는 돈',
        body: '저축의 이자, 주식의 배당금처럼 내가 쉬는 동안에도 들어오는 돈이에요. '
            '서원이의 저축 이자가 바로 이거예요!',
      ),
    ],
    callout: '어른들은 보통 여러 갈래를 함께 만들어요. 한 곳이 막혀도 버틸 수 있게요.',
  ),
  EconomyTopic(
    id: 'bank_account',
    emoji: '🏦',
    title: '통장과 계좌',
    summary: '은행에 있는 나만의 돈 보관함',
    sections: [
      TopicSection(
        emoji: '📗',
        title: '계좌 — 은행 속 내 자리',
        body: '은행에 내 이름으로 만든 돈 보관함이 계좌예요. '
            '계좌번호는 그 보관함의 주소죠.',
      ),
      TopicSection(
        emoji: '🔢',
        title: '계좌번호는 알려줘도 돼요',
        body: '돈을 받으려면 계좌번호를 알려줘야 해요. 이건 괜찮아요. '
            '하지만 비밀번호와 인증번호는 절대 알려주면 안 돼요.',
      ),
      TopicSection(
        emoji: '👨‍👩‍👦',
        title: '어린이 통장도 있어요',
        body: '부모님과 함께 은행에 가면 만들 수 있어요. '
            '저금통보다 안전하고 이자도 붙어요.',
      ),
    ],
    callout: '계좌번호는 주소, 비밀번호는 열쇠예요. 열쇠는 절대 남에게 주지 마세요!',
  ),
  EconomyTopic(
    id: 'transfer',
    emoji: '📲',
    title: '이체와 송금',
    summary: '돈을 손에 들지 않고 옮기는 법',
    sections: [
      TopicSection(
        emoji: '➡️',
        title: '통장에서 통장으로',
        body: '현금을 들고 가지 않아도 계좌에서 계좌로 돈을 보낼 수 있어요. '
            '숫자만 옮겨 적는 셈이에요.',
      ),
      TopicSection(
        emoji: '🔍',
        title: '보내기 전에 두 번 확인',
        body: '계좌번호를 하나만 잘못 눌러도 엉뚱한 사람에게 가요. '
            '받는 사람 이름이 맞는지 꼭 확인하세요.',
      ),
      TopicSection(
        emoji: '↩️',
        title: '잘못 보내면 되돌리기 어려워요',
        body: '받은 사람이 돌려줘야 돌아와요. 은행이 마음대로 뺏어올 수 없거든요. '
            '그래서 보내기 전 확인이 중요해요.',
      ),
    ],
    callout: '큰돈을 보낼 땐 꼭 어른과 함께 하세요!',
  ),
  EconomyTopic(
    id: 'installment',
    emoji: '📅',
    title: '할부가 뭐야?',
    summary: '나눠 내면 편하지만 조심할 게 있어요',
    sections: [
      TopicSection(
        emoji: '✂️',
        title: '값을 여러 달로 쪼개는 것',
        body: '12만원짜리를 12개월 할부로 사면 매달 1만원씩 내요. '
            '한 번에 큰돈이 안 나가서 편해 보이죠.',
      ),
      TopicSection(
        emoji: '➕',
        title: '보통은 이자가 붙어요',
        body: '무이자가 아니면 나눠 내는 값에 이자가 더해져요. '
            '결국 원래 값보다 더 내는 거예요.',
      ),
      TopicSection(
        emoji: '🧊',
        title: '싸게 느껴지는 착시',
        body: '"한 달에 1만원"이라고 하면 싸 보여요. 하지만 총액은 12만원이에요. '
            '항상 총액으로 생각하세요.',
      ),
    ],
    callout: '할부가 쌓이면 매달 나갈 돈이 미리 정해져 버려요. 신중하게!',
  ),
  EconomyTopic(
    id: 'points',
    emoji: '⭐',
    title: '포인트와 마일리지',
    summary: '작지만 진짜 돈이에요',
    sections: [
      TopicSection(
        emoji: '🎁',
        title: '왜 포인트를 줄까?',
        body: '다음에 또 오게 하려고요. 포인트가 쌓이면 그 가게를 계속 가게 되거든요.',
      ),
      TopicSection(
        emoji: '💸',
        title: '포인트도 돈이에요',
        body: '1포인트가 1원인 곳이 많아요. 모으면 실제로 물건을 살 수 있죠. '
            '그냥 버리지 마세요.',
      ),
      TopicSection(
        emoji: '⌛',
        title: '사라지기도 해요',
        body: '포인트는 유효기간이 있는 경우가 많아요. '
            '가끔 확인해서 없어지기 전에 쓰세요.',
      ),
    ],
    callout: '포인트를 모으려고 필요 없는 걸 사면 오히려 손해예요!',
  ),
  EconomyTopic(
    id: 'fees',
    emoji: '🚚',
    title: '배달비와 수수료',
    summary: '물건값 말고 더 나가는 돈',
    sections: [
      TopicSection(
        emoji: '🛵',
        title: '배달비는 서비스 값이에요',
        body: '누군가 가져다주는 수고에 내는 돈이에요. '
            '음식값은 같아도 배달비 때문에 총액이 달라져요.',
      ),
      TopicSection(
        emoji: '🧾',
        title: '수수료도 여기저기 숨어 있어요',
        body: '다른 은행 ATM에서 뽑을 때, 티켓을 예매할 때도 수수료가 붙어요. '
            '작아 보여도 쌓이면 커요.',
      ),
      TopicSection(
        emoji: '🔎',
        title: '결제 직전 총액을 보세요',
        body: '"3,000원"인 줄 알았는데 마지막에 5,500원이 되기도 해요. '
            '결제 버튼 누르기 전 숫자를 확인하세요.',
      ),
    ],
    callout: '친구와 함께 시키면 배달비를 나눌 수 있어요. 이것도 똑똑한 소비!',
  ),
  EconomyTopic(
    id: 'phone_plan',
    emoji: '📱',
    title: '휴대폰 요금',
    summary: '매달 자동으로 나가는 큰돈',
    sections: [
      TopicSection(
        emoji: '📶',
        title: '요금제 — 매달 정해진 돈',
        body: '전화·문자·데이터를 얼마나 쓸지 미리 정하고 매달 돈을 내요. '
            '많이 쓰는 요금제일수록 비싸요.',
      ),
      TopicSection(
        emoji: '🎬',
        title: '데이터를 많이 먹는 것들',
        body: '영상 보기와 게임이 데이터를 가장 많이 써요. '
            '와이파이에서 보면 데이터가 안 줄어요.',
      ),
      TopicSection(
        emoji: '💡',
        title: '내가 쓰는 만큼만',
        body: '안 쓰는데 비싼 요금제면 돈이 새요. '
            '얼마나 쓰는지 보고 맞는 걸 고르는 게 좋아요.',
      ),
    ],
    callout: '가족 요금제로 묶으면 더 싸지기도 해요. 부모님께 여쭤보세요!',
  ),
  EconomyTopic(
    id: 'housing',
    emoji: '🏡',
    title: '집에 드는 돈',
    summary: '사는 것과 빌리는 것',
    sections: [
      TopicSection(
        emoji: '🔑',
        title: '사거나, 빌리거나',
        body: '집을 사면 내 것이 되고, 빌리면 매달 돈을 내요. '
            '집은 아주 비싸서 대부분 은행에서 빌려 사요.',
      ),
      TopicSection(
        emoji: '💳',
        title: '월세와 전세',
        body: '월세는 매달 돈을 내는 것, 전세는 큰돈을 맡기고 살다가 나갈 때 돌려받는 방식이에요. '
            '전세는 우리나라에만 거의 있어요.',
      ),
      TopicSection(
        emoji: '📈',
        title: '집값도 오르내려요',
        body: '집도 사고파는 것이라 값이 변해요. 오를 때도 있고 내릴 때도 있어요.',
      ),
    ],
    callout: '어른들이 "대출"을 말할 때 대부분 집 때문이에요!',
  ),
  EconomyTopic(
    id: 'unemployment',
    emoji: '😟',
    title: '실업이 뭐야?',
    summary: '일하고 싶은데 일자리가 없는 것',
    sections: [
      TopicSection(
        emoji: '🔍',
        title: '일을 찾고 있는 상태',
        body: '일할 마음도 있고 할 수 있는데 자리가 없는 걸 실업이라고 해요. '
            '쉬고 싶어서 안 하는 건 실업이 아니에요.',
      ),
      TopicSection(
        emoji: '📉',
        title: '불황일 때 늘어나요',
        body: '경제가 어려우면 회사가 사람을 덜 뽑아요. '
            '그래서 불황과 실업은 같이 다녀요.',
      ),
      TopicSection(
        emoji: '🤝',
        title: '나라가 도와줘요',
        body: '실업급여로 잠시 버틸 돈을 주고, 새 기술을 배우게 도와줘요. '
            '세금이 이런 데 쓰여요.',
      ),
    ],
    callout: '뉴스의 "실업률"은 일자리를 찾는 사람이 얼마나 많은지 보여주는 숫자예요.',
  ),
  EconomyTopic(
    id: 'rate_effect',
    emoji: '🎚️',
    title: '금리가 오르면 무슨 일이?',
    summary: '금리 하나로 온 나라가 움직여요',
    sections: [
      TopicSection(
        emoji: '🏦',
        title: '저축하는 사람은 좋아요',
        body: '금리가 오르면 은행이 주는 이자가 늘어요. '
            '모아둔 돈이 더 빨리 자라죠.',
      ),
      TopicSection(
        emoji: '😰',
        title: '빌린 사람은 힘들어요',
        body: '갚아야 할 이자도 같이 올라요. '
            '집을 사려고 빌린 사람들이 특히 힘들어져요.',
      ),
      TopicSection(
        emoji: '🧊',
        title: '그래서 물가가 진정돼요',
        body: '사람들이 돈을 아끼게 되니 물건이 덜 팔리고 값도 덜 올라요. '
            '중앙은행이 금리로 물가를 잡는 이유예요.',
      ),
    ],
    callout: '홈 화면 기준금리가 오르면 서원이 이자도 같이 올라요!',
  ),
  EconomyTopic(
    id: 'brand',
    emoji: '🏷️',
    title: '브랜드가 뭐야?',
    summary: '이름값이 붙는 이유',
    sections: [
      TopicSection(
        emoji: '👟',
        title: '같은 신발인데 값이 달라요',
        body: '비슷해 보여도 유명한 이름이 붙으면 비싸요. '
            '그 이름을 믿는 사람이 많기 때문이에요.',
      ),
      TopicSection(
        emoji: '⏳',
        title: '믿음은 오래 쌓여요',
        body: '오랫동안 좋은 물건을 만들면 사람들이 믿게 돼요. '
            '그 믿음이 브랜드의 값이에요.',
      ),
      TopicSection(
        emoji: '🤔',
        title: '이름값이 항상 옳진 않아요',
        body: '비싼 게 늘 더 좋진 않아요. '
            '진짜 내게 필요한 성능인지 따져보세요.',
      ),
    ],
    callout: '친구가 다 가진 브랜드라고 나도 꼭 필요한 건 아니에요!',
  ),
  EconomyTopic(
    id: 'innovation',
    emoji: '💡',
    title: '새로운 것이 나오면',
    summary: '혁신이 값을 바꿔요',
    sections: [
      TopicSection(
        emoji: '📼',
        title: '옛것은 사라져요',
        body: '비디오테이프, 삐삐, MP3 플레이어는 이제 거의 안 써요. '
            '더 좋은 게 나오면 자리를 내줘요.',
      ),
      TopicSection(
        emoji: '📉',
        title: '처음엔 비싸다 점점 싸져요',
        body: '새 기술은 처음엔 비싸요. 많이 만들수록 값이 내려가죠. '
            '텔레비전도 예전엔 아주 비쌌어요.',
      ),
      TopicSection(
        emoji: '🚀',
        title: '새 일자리도 생겨요',
        body: '없어지는 일이 있으면 새로 생기는 일도 있어요. '
            '유튜버는 20년 전엔 없던 직업이에요.',
      ),
    ],
    callout: '지금 인기 있는 것도 언젠가 바뀌어요. 배우는 힘이 제일 중요해요!',
  ),
  EconomyTopic(
    id: 'scale_economy',
    emoji: '📦',
    title: '많이 만들면 싸져요',
    summary: '규모의 경제',
    sections: [
      TopicSection(
        emoji: '🏭',
        title: '기계값은 한 번만 들어요',
        body: '빵 만드는 기계를 사면, 10개를 만들든 1,000개를 만들든 기계값은 같아요. '
            '많이 만들수록 하나당 값이 싸지죠.',
      ),
      TopicSection(
        emoji: '🛒',
        title: '대용량이 싼 이유',
        body: '큰 봉지 과자가 작은 봉지보다 100g당 싼 건 이 때문이에요. '
            '포장·운반 비용을 나눠 쓰거든요.',
      ),
      TopicSection(
        emoji: '⚠️',
        title: '무조건 좋진 않아요',
        body: '다 못 먹고 버리면 오히려 손해예요. '
            '많이 살 땐 정말 다 쓸지 생각해보세요.',
      ),
    ],
    callout: '단위당 가격을 비교하면 진짜 싼지 알 수 있어요!',
  ),
  EconomyTopic(
    id: 'price_index',
    emoji: '📊',
    title: '물가지수 읽는 법',
    summary: '작년보다 얼마나 올랐나',
    sections: [
      TopicSection(
        emoji: '🧺',
        title: '장바구니를 통째로 비교해요',
        body: '한 가지 물건만 보면 안 돼요. 사람들이 자주 사는 것들을 바구니에 담아 '
            '작년과 값을 비교해요.',
      ),
      TopicSection(
        emoji: '💯',
        title: '기준을 100으로 둬요',
        body: '어느 해를 100으로 정하고, 지금이 103이면 3% 올랐다는 뜻이에요.',
      ),
      TopicSection(
        emoji: '🆚',
        title: '내 이자와 비교해보세요',
        body: '물가가 3% 오르는데 이자가 2%면 실제로는 손해예요. '
            '진짜 이득은 이자에서 물가를 뺀 만큼이에요.',
      ),
    ],
    callout: '경제왕 탭에서 지금 물가가 얼마나 올랐는지 볼 수 있어요!',
  ),
  EconomyTopic(
    id: 'review_trust',
    emoji: '🌟',
    title: '리뷰와 별점 믿기',
    summary: '좋은 말만 있다면 의심해보세요',
    sections: [
      TopicSection(
        emoji: '🎭',
        title: '가짜 리뷰도 있어요',
        body: '돈을 받고 좋은 말만 써주는 경우가 있어요. '
            '모두 별 다섯 개에 칭찬만 있으면 오히려 이상해요.',
      ),
      TopicSection(
        emoji: '🔍',
        title: '낮은 별점을 먼저 보세요',
        body: '별 하나·둘짜리 리뷰에 진짜 단점이 적혀 있어요. '
            '그 단점을 내가 견딜 수 있는지 보면 돼요.',
      ),
      TopicSection(
        emoji: '📸',
        title: '사진 있는 후기가 믿을 만해요',
        body: '실제로 받은 사진을 올린 후기가 더 믿음직해요. '
            '글만 짧게 있는 건 조심하세요.',
      ),
    ],
    callout: '리뷰는 참고일 뿐, 결정은 내가 하는 거예요!',
  ),
  EconomyTopic(
    id: 'influencer',
    emoji: '🎥',
    title: '유명인이 쓰는 물건',
    summary: '광고인지 아닌지 봐야 해요',
    sections: [
      TopicSection(
        emoji: '💼',
        title: '돈을 받고 소개하기도 해요',
        body: '좋아하는 유튜버가 소개한 물건이 광고일 수 있어요. '
            '"유료 광고 포함"이라고 적혀 있는지 보세요.',
      ),
      TopicSection(
        emoji: '🪞',
        title: '따라 산다고 그 사람이 되진 않아요',
        body: '같은 신발을 신어도 그 사람처럼 되진 않아요. '
            '내게 필요한지가 기준이에요.',
      ),
      TopicSection(
        emoji: '⏸️',
        title: '하루만 참아보기',
        body: '영상을 본 직후엔 사고 싶은 마음이 가장 커요. '
            '하루 지나고도 갖고 싶으면 그때 생각해도 늦지 않아요.',
      ),
    ],
    callout: '광고를 알아보는 눈이 있으면 돈을 훨씬 아낄 수 있어요!',
  ),
  EconomyTopic(
    id: 'free_trial',
    emoji: '🎣',
    title: '무료 체험의 함정',
    summary: '공짜로 시작해서 돈이 나가요',
    sections: [
      TopicSection(
        emoji: '🆓',
        title: '처음 한 달은 공짜',
        body: '많은 서비스가 첫 달을 공짜로 줘요. 써보게 하려는 거죠. '
            '여기까진 좋아요.',
      ),
      TopicSection(
        emoji: '🔁',
        title: '안 끊으면 자동으로 결제돼요',
        body: '체험이 끝나면 알아서 돈이 빠져나가요. '
            '깜빡하면 안 쓰는데 계속 내게 돼요.',
      ),
      TopicSection(
        emoji: '⏰',
        title: '신청할 때 바로 알림 설정',
        body: '무료 체험을 시작하면 끝나는 날에 알림을 맞춰두세요. '
            '계속 쓸지 그때 정하면 돼요.',
      ),
    ],
    callout: '공짜라는 말이 나오면 "언제부터 돈이 나가지?"를 먼저 물어보세요!',
  ),
  EconomyTopic(
    id: 'eco_consumption',
    emoji: '♻️',
    title: '지구를 생각하는 소비',
    summary: '어떻게 쓰느냐도 선택이에요',
    sections: [
      TopicSection(
        emoji: '🌏',
        title: '물건 하나에도 자원이 들어요',
        body: '만들고 옮기는 데 나무·물·기름이 쓰여요. '
            '덜 사고 오래 쓰는 게 지구를 돕는 일이에요.',
      ),
      TopicSection(
        emoji: '🔄',
        title: '고쳐 쓰고 물려주기',
        body: '망가졌다고 바로 버리지 말고 고쳐보세요. '
            '안 쓰는 건 동생이나 친구에게 물려줘도 좋아요.',
      ),
      TopicSection(
        emoji: '🛍️',
        title: '내 선택이 회사를 바꿔요',
        body: '환경을 생각하는 회사 물건을 사면 그런 회사가 늘어요. '
            '소비도 일종의 투표예요.',
      ),
    ],
    callout: '돈도 아끼고 지구도 지키는 가장 쉬운 방법은 덜 사는 거예요!',
  ),
  EconomyTopic(
    id: 'volunteer',
    emoji: '🙌',
    title: '기부와 봉사',
    summary: '돈으로도, 시간으로도 도울 수 있어요',
    sections: [
      TopicSection(
        emoji: '💝',
        title: '기부 — 돈으로 돕기',
        body: '내 돈의 일부를 필요한 사람에게 보내는 거예요. '
            '작은 돈도 모이면 큰 힘이 돼요.',
      ),
      TopicSection(
        emoji: '⏱️',
        title: '봉사 — 시간으로 돕기',
        body: '돈이 없어도 도울 수 있어요. 시간과 손을 쓰는 거죠. '
            '시간도 소중한 자원이니까요.',
      ),
      TopicSection(
        emoji: '🔍',
        title: '어디에 쓰이는지 보기',
        body: '기부한 돈이 잘 쓰이는지 알려주는 곳에 하는 게 좋아요. '
            '부모님과 함께 알아보세요.',
      ),
    ],
    callout: '용돈에서 나눌 몫을 정해두면 부담 없이 꾸준히 할 수 있어요!',
  ),
  EconomyTopic(
    id: 'inheritance',
    emoji: '🎁',
    title: '물려주고 물려받기',
    summary: '돈도 다음 사람에게 이어져요',
    sections: [
      TopicSection(
        emoji: '👵',
        title: '상속 — 물려받는 것',
        body: '가족이 세상을 떠나면 그분의 돈과 집이 가족에게 넘어가요. '
            '이걸 상속이라고 해요.',
      ),
      TopicSection(
        emoji: '🧾',
        title: '여기에도 세금이 붙어요',
        body: '많이 물려받으면 상속세를 내요. '
            '한 집에만 재산이 계속 쌓이지 않게 하려는 거예요.',
      ),
      TopicSection(
        emoji: '📚',
        title: '돈보다 중요한 것도 있어요',
        body: '아껴 쓰는 습관, 배우는 태도 같은 건 돈보다 오래가요. '
            '이것도 물려받는 거예요.',
      ),
    ],
    callout: '지금 만드는 저축 습관이 평생 갈 재산이에요!',
  ),
  EconomyTopic(
    id: 'deposit_money',
    emoji: '🔒',
    title: '보증금이 뭐야?',
    summary: '맡겨두고 나중에 돌려받는 돈',
    sections: [
      TopicSection(
        emoji: '🤝',
        title: '약속을 지키겠다는 표시',
        body: '집을 빌릴 때, 물건을 빌릴 때 미리 맡기는 돈이에요. '
            '문제없이 돌려주면 그대로 받아요.',
      ),
      TopicSection(
        emoji: '💧',
        title: '깨거나 망가뜨리면 빼요',
        body: '빌린 걸 망가뜨리면 고치는 값만큼 빼고 돌려줘요. '
            '그래서 조심해서 써야 해요.',
      ),
      TopicSection(
        emoji: '📝',
        title: '얼마 맡겼는지 적어두기',
        body: '돌려받아야 할 돈이니 기록해두세요. '
            '잊어버리면 못 받을 수도 있어요.',
      ),
    ],
    callout: '보증금은 쓴 돈이 아니라 잠시 맡긴 돈이에요!',
  ),
  EconomyTopic(
    id: 'travel_budget',
    emoji: '🧳',
    title: '여행 예산 짜기',
    summary: '미리 나눠두면 마음이 편해요',
    sections: [
      TopicSection(
        emoji: '📋',
        title: '뭐에 쓸지 나눠보기',
        body: '교통비, 먹을 것, 기념품처럼 종류별로 나눠 미리 정해요. '
            '그러면 한 곳에서 다 써버리지 않아요.',
      ),
      TopicSection(
        emoji: '🎁',
        title: '기념품은 마지막 날에',
        body: '처음에 다 사면 나중에 더 좋은 걸 봐도 못 사요. '
            '조금 남겨두면 여유가 생겨요.',
      ),
      TopicSection(
        emoji: '🪙',
        title: '남으면 그대로 저축',
        body: '아껴서 남은 돈은 다시 모으면 돼요. '
            '다음 여행이 더 빨리 와요.',
      ),
    ],
    callout: '여행 전에 용돈기입장을 미리 써보면 계획이 훨씬 잘 세워져요!',
  ),
  EconomyTopic(
    id: 'gift_budget',
    emoji: '🎀',
    title: '선물 사는 요령',
    summary: '값보다 마음이 크게 보여요',
    sections: [
      TopicSection(
        emoji: '💭',
        title: '상대가 좋아할 걸 먼저',
        body: '비싼 것보다 그 사람이 정말 좋아하는 게 좋은 선물이에요. '
            '평소에 뭘 말했는지 떠올려보세요.',
      ),
      TopicSection(
        emoji: '💰',
        title: '얼마까지 쓸지 먼저 정하기',
        body: '고르다 보면 자꾸 비싼 게 눈에 들어와요. '
            '먼저 정해두면 흔들리지 않아요.',
      ),
      TopicSection(
        emoji: '✍️',
        title: '직접 만들면 더 특별해요',
        body: '편지나 손으로 만든 것은 돈이 거의 안 들어도 오래 기억돼요.',
      ),
    ],
    callout: '선물할 돈도 미리 조금씩 모아두면 부담이 없어요!',
  ),
  EconomyTopic(
    id: 'over_budget',
    emoji: '🚨',
    title: '예산을 넘겼을 때',
    summary: '실수는 누구나 해요. 중요한 건 다음',
    sections: [
      TopicSection(
        emoji: '🔍',
        title: '어디서 새는지 찾기',
        body: '먼저 무엇에 많이 썼는지 봐요. '
            '앱의 카테고리별 지출을 보면 금방 보여요.',
      ),
      TopicSection(
        emoji: '⏸️',
        title: '다음 주에 조금 줄이기',
        body: '한꺼번에 메우려 하면 힘들어요. '
            '다음 주에 조금만 아끼면 금방 돌아와요.',
      ),
      TopicSection(
        emoji: '🚫',
        title: '빌려서 메우진 않기',
        body: '모자란다고 빌리면 다음 주가 더 힘들어져요. '
            '한 번 늦으면 계속 밀리거든요.',
      ),
    ],
    callout: '넘긴 걸 숨기지 말고 적어두세요. 기록이 있어야 고칠 수 있어요!',
  ),
  EconomyTopic(
    id: 'auto_saving',
    emoji: '🤖',
    title: '저절로 모이게 만들기',
    summary: '의지보다 구조가 세요',
    sections: [
      TopicSection(
        emoji: '⚡',
        title: '받자마자 먼저 떼기',
        body: '쓰고 남은 걸 모으면 잘 안 모여요. '
            '용돈을 받는 순간 저축할 몫을 먼저 옮기세요.',
      ),
      TopicSection(
        emoji: '🙈',
        title: '눈에 안 보이게 두기',
        body: '보이면 쓰고 싶어져요. 저금통이나 다른 통장에 넣어 '
            '평소에 안 보이게 하면 훨씬 잘 모여요.',
      ),
      TopicSection(
        emoji: '📏',
        title: '작게 시작해서 늘리기',
        body: '처음부터 절반을 모으면 힘들어요. '
            '10%로 시작해서 익숙해지면 조금씩 올리세요.',
      ),
    ],
    callout: '참는 힘에 기대지 말고, 안 쓰게 되는 방법을 만드는 게 진짜 요령이에요!',
  ),
  EconomyTopic(
    id: 'money_happiness',
    emoji: '😊',
    title: '돈과 행복',
    summary: '돈은 도구지 목표가 아니에요',
    sections: [
      TopicSection(
        emoji: '🪜',
        title: '어느 정도까진 도움이 돼요',
        body: '먹을 것과 잘 곳이 없으면 힘들어요. '
            '기본이 채워질 때까지는 돈이 행복을 크게 늘려줘요.',
      ),
      TopicSection(
        emoji: '📉',
        title: '그 뒤로는 천천히 늘어요',
        body: '충분해진 다음엔 돈이 두 배가 돼도 행복이 두 배가 되진 않아요. '
            '금방 익숙해지거든요.',
      ),
      TopicSection(
        emoji: '💞',
        title: '경험과 사람이 오래가요',
        body: '물건은 금방 질리지만 가족과 간 여행, 친구와 논 기억은 오래 남아요.',
      ),
    ],
    callout: '돈을 모으는 이유를 가끔 떠올려보세요. 그게 방향을 잡아줘요!',
  ),
  EconomyTopic(
    id: 'atm',
    emoji: '🏧',
    title: 'ATM 쓰는 법',
    summary: '은행이 문을 닫아도 쓸 수 있어요',
    sections: [
      TopicSection(
        emoji: '💳',
        title: '카드와 비밀번호가 필요해요',
        body: '카드를 넣고 비밀번호를 눌러 돈을 찾거나 넣을 수 있어요. '
            '비밀번호는 가리고 누르세요.',
      ),
      TopicSection(
        emoji: '💸',
        title: '수수료가 붙을 때가 있어요',
        body: '내 은행이 아닌 ATM이나 밤늦게 쓰면 수수료가 붙어요. '
            '몇백 원이지만 자주 하면 쌓여요.',
      ),
      TopicSection(
        emoji: '👀',
        title: '카드와 돈 꼭 챙기기',
        body: '돈만 들고 카드를 두고 오는 실수가 많아요. '
            '자리를 뜨기 전에 한 번 더 확인하세요.',
      ),
    ],
    callout: '내 은행 ATM을 낮에 쓰면 수수료를 아낄 수 있어요!',
  ),
  EconomyTopic(
    id: 'exchange_money',
    emoji: '💱',
    title: '환전하기',
    summary: '다른 나라 돈으로 바꾸기',
    sections: [
      TopicSection(
        emoji: '✈️',
        title: '여행 갈 때 바꿔요',
        body: '일본에 가면 엔, 미국에 가면 달러가 필요해요. '
            '은행이나 공항에서 바꿀 수 있어요.',
      ),
      TopicSection(
        emoji: '🏦',
        title: '어디서 바꾸냐에 따라 달라요',
        body: '공항은 편하지만 조금 손해예요. '
            '미리 은행 앱으로 신청하면 더 좋은 값에 바꿀 수 있어요.',
      ),
      TopicSection(
        emoji: '🔙',
        title: '남은 돈은 다시 바꿔요',
        body: '쓰고 남은 외국 돈은 돌아와서 다시 바꿀 수 있어요. '
            '동전은 안 받는 곳이 많으니 다 쓰고 오면 좋아요.',
      ),
    ],
    callout: '환율이 좋을 때 미리 조금씩 바꿔두는 어른들도 있어요!',
  ),
  EconomyTopic(
    id: 'saving_together',
    emoji: '👨‍👩‍👧‍👦',
    title: '같이 모으면 더 커져요',
    summary: '가족과 함께하는 목표',
    sections: [
      TopicSection(
        emoji: '🎯',
        title: '함께 정한 목표는 힘이 세요',
        body: '가족 여행처럼 같이 원하는 걸 정하고 조금씩 모아보세요. '
            '혼자보다 훨씬 빨리 모여요.',
      ),
      TopicSection(
        emoji: '📊',
        title: '얼마나 왔는지 같이 보기',
        body: '진행률이 보이면 더 하고 싶어져요. '
            '앱의 저축 목표를 함께 확인해보세요.',
      ),
      TopicSection(
        emoji: '🎉',
        title: '이루면 같이 기뻐하기',
        body: '목표를 이루면 꼭 축하해요. '
            '그 기억이 다음 목표를 만드는 힘이 돼요.',
      ),
    ],
    callout: '앱의 저축 목표에 가족 목표를 하나 만들어보세요!',
  ),
];

EconomyTopic? topicById(String id) {
  for (final t in kEconomyTopics) {
    if (t.id == id) return t;
  }
  return null;
}
