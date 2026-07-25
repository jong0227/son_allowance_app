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
];

EconomyTopic? topicById(String id) {
  for (final t in kEconomyTopics) {
    if (t.id == id) return t;
  }
  return null;
}
