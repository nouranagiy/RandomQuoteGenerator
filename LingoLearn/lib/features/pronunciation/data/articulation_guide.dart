class ArticulationTip {
  final String en;
  final String ar;

  const ArticulationTip(this.en, this.ar);
}

/// Data-driven articulation coaching for English phonemes as returned by the
/// Azure pronunciation assessment (ARPAbet-style phone labels, with common
/// IPA spellings mapped to the same guidance). Unknown phones fall back to a
/// generic imitation tip at the UI layer.
class ArticulationGuide {
  ArticulationGuide._();

  static final Map<String, ArticulationTip> _tips = {
    // Vowels
    'iy': const ArticulationTip(
      "The long 'ee' vowel: spread your lips into a wide smile, keep the "
          'tongue high and forward, and hold the sound steady.',
      "صوت 'إي' الطويل: باعد شفتيك بابتسامة عريضة، أبقِ اللسان مرتفعاً نحو الأمام وثبّت الصوت.",
    ),
    'iː': const ArticulationTip(
      "The long 'ee' vowel: spread your lips into a wide smile, keep the "
          'tongue high and forward, and hold the sound steady.',
      "صوت 'إي' الطويل: باعد شفتيك بابتسامة عريضة، أبقِ اللسان مرتفعاً نحو الأمام وثبّت الصوت.",
    ),
    'ih': const ArticulationTip(
      "The short 'i' vowel (as in 'sit'): keep your lips relaxed, tongue a "
          'little high and forward, and make the sound short.',
      "صوت 'إي' القصير (مثل 'sit'): أبقِ شفتيك مرتاحتين، اللسان مرتفعاً قليلاً للأمام والصوت قصيراً.",
    ),
    'ɪ': const ArticulationTip(
      "The short 'i' vowel (as in 'sit'): keep your lips relaxed, tongue a "
          'little high and forward, and make the sound short.',
      "صوت 'إي' القصير (مثل 'sit'): أبقِ شفتيك مرتاحتين، اللسان مرتفعاً قليلاً للأمام والصوت قصيراً.",
    ),
    'eh': const ArticulationTip(
      "The 'e' vowel (as in 'bed'): relax your lips and open the mouth a "
          'little, tongue middle and forward.',
      "صوت 'e' (مثل 'bed'): أرخِ شفتيك وافتح فمك قليلاً، واللسان في المنتصف نحو الأمام.",
    ),
    'e': const ArticulationTip(
      "The 'e' vowel (as in 'bed'): relax your lips and open the mouth a "
          'little, tongue middle and forward.',
      "صوت 'e' (مثل 'bed'): أرخِ شفتيك وافتح فمك قليلاً، واللسان في المنتصف نحو الأمام.",
    ),
    'ae': const ArticulationTip(
      "The 'a' vowel (as in 'cat'): drop your jaw and keep the tongue low at "
          'the front — say "a" with a wide mouth.',
      "صوت 'a' (مثل 'cat'): انزل بفكك وأبقِ اللسان منخفضاً في المقدمة — انطقه وفمك مفتوح.",
    ),
    'æ': const ArticulationTip(
      "The 'a' vowel (as in 'cat'): drop your jaw and keep the tongue low at "
          'the front — say "a" with a wide mouth.',
      "صوت 'a' (مثل 'cat'): انزل بفكك وأبقِ اللسان منخفضاً في المقدمة — انطقه وفمك مفتوح.",
    ),
    'aa': const ArticulationTip(
      "The 'a' vowel (as in 'father'): drop the jaw, keep the tongue low and "
          'back, and hold a steady sound.',
      "صوت 'a' (مثل 'father'): افتح فكك، اللسان منخفض إلى الخلف، والصوت ثابت.",
    ),
    'ɑː': const ArticulationTip(
      "The 'a' vowel (as in 'father'): drop the jaw, keep the tongue low and "
          'back, and hold a steady sound.',
      "صوت 'a' (مثل 'father'): افتح فكك، اللسان منخفض إلى الخلف، والصوت ثابت.",
    ),
    'ao': const ArticulationTip(
      "The 'o' vowel (as in 'thought'): round your lips and lower the jaw, "
          'tongue low and slightly back.',
      "صوت 'o' (مثل 'thought'): استدر شفتيك واخفض فكك، اللسان منخفض قليلاً إلى الخلف.",
    ),
    'ɔ': const ArticulationTip(
      "The 'o' vowel (as in 'thought'): round your lips and lower the jaw, "
          'tongue low and slightly back.',
      "صوت 'o' (مثل 'thought'): استدر شفتيك واخفض فكك، اللسان منخفض قليلاً إلى الخلف.",
    ),
    'uw': const ArticulationTip(
      "The long 'oo' vowel (as in 'boot'): round your lips and push them "
          'forward, tongue high and back.',
      "صوت 'أو' الطويل (مثل 'boot'): دوّر شفتيك وقدّمهما للأمام، اللسان مرتفع للخلف.",
    ),
    'uː': const ArticulationTip(
      "The long 'oo' vowel (as in 'boot'): round your lips and push them "
          'forward, tongue high and back.',
      "صوت 'أو' الطويل (مثل 'boot'): دوّر شفتيك وقدّمهما للأمام، اللسان مرتفع للخلف.",
    ),
    'uh': const ArticulationTip(
      "The relaxed 'uh' vowel (as in 'about'): everything neutral, mouth "
          'barely open, no effort.',
      "صوت 'أ' المهمل (مثل 'about'): كل شيء متعادل، الفم مفتوح قليلاً دون مجهود.",
    ),
    'ax': const ArticulationTip(
      "The relaxed 'uh' vowel (as in 'about'): everything neutral, mouth "
          'barely open, no effort.',
      "صوت 'أ' المهمل (مثل 'about'): كل شيء متعادل، الفم مفتوح قليلاً دون مجهود.",
    ),
    'ə': const ArticulationTip(
      "The relaxed 'uh' vowel (as in 'about'): everything neutral, mouth "
          'barely open, no effort.',
      "صوت 'أ' المهمل (مثل 'about'): كل شيء متعادل، الفم مفتوح قليلاً دون مجهود.",
    ),
    'ʌ': const ArticulationTip(
      "The 'uh' vowel (as in 'cup'): neutral lips, jaw slightly open, tongue "
          'low and central.',
      "صوت 'أ' (مثل 'cup'): شفاه متعادلة، فك مفتوح قليلاً، اللسان منخفض في الوسط.",
    ),
    'ow': const ArticulationTip(
      "The 'o' glide (as in 'go'): start with a relaxed 'oh' and gently round "
          'the lips as the sound ends.',
      "صوت 'اُو' (مثل 'go'): ابدأ بـ'أوه' مريح ثم دوّر شفتيك بلطف عند نهاية الصوت.",
    ),
    'oʊ': const ArticulationTip(
      "The 'o' glide (as in 'go'): start with a relaxed 'oh' and gently round "
          'the lips as the sound ends.',
      "صوت 'اُو' (مثل 'go'): ابدأ بـ'أوه' مريح ثم دوّر شفتيك بلطف عند نهاية الصوت.",
    ),
    'əʊ': const ArticulationTip(
      "The 'o' glide (as in 'go'): start with a relaxed 'oh' and gently round "
          'the lips as the sound ends.',
      "صوت 'اُو' (مثل 'go'): ابدأ بـ'أوه' مريح ثم دوّر شفتيك بلطف عند نهاية الصوت.",
    ),
    'aw': const ArticulationTip(
      "The 'ow' glide (as in 'how'): start with a wide 'a' then glide to a "
          'rounded "oo" — move the jaw from open to closed.',
      "صوت 'آو' (مثل 'how'): ابدأ بـ'آ' واسعة ثم انزلق إلى 'أو' مستديرة — حرّك الفك من الفتح إلى الإغلاق.",
    ),
    'aʊ': const ArticulationTip(
      "The 'ow' glide (as in 'how'): start with a wide 'a' then glide to a "
          'rounded "oo" — move the jaw from open to closed.',
      "صوت 'آو' (مثل 'how'): ابدأ بـ'آ' واسعة ثم انزلق إلى 'أو' مستديرة — حرّك الفك من الفتح إلى الإغلاق.",
    ),
    'ay': const ArticulationTip(
      "The 'i' glide (as in 'my'): start with a relaxed 'ah' and glide to "
          "'ee', moving the tongue forward and up.",
      "صوت 'أي' (مثل 'my'): ابدأ بـ'أه' مريح وانزلق إلى 'إي' محركاً اللسان للأعلى.",
    ),
    'aɪ': const ArticulationTip(
      "The 'i' glide (as in 'my'): start with a relaxed 'ah' and glide to "
          "'ee', moving the tongue forward and up.",
      "صوت 'أي' (مثل 'my'): ابدأ بـ'أه' مريح وانزلق إلى 'إي' محركاً اللسان للأعلى.",
    ),
    'ey': const ArticulationTip(
      "The 'ay' glide (as in 'say'): start with a middle 'e' and end with a "
          "short 'ee', with a slight smile.",
      "صوت 'إي' المتموج (مثل 'say'): ابدأ بـ'e' متوسط وأنهِ بـ'إي' قصيرة مع ابتسامة خفيفة.",
    ),
    'eɪ': const ArticulationTip(
      "The 'ay' glide (as in 'say'): start with a middle 'e' and end with a "
          "short 'ee', with a slight smile.",
      "صوت 'إي' المتموج (مثل 'say'): ابدأ بـ'e' متوسط وأنهِ بـ'إي' قصيرة مع ابتسامة خفيفة.",
    ),
    'oy': const ArticulationTip(
      "The 'oy' glide (as in 'boy'): start with a rounded 'o' and glide to "
          "'ee'. ",
      "صوت 'أوي' (مثل 'boy'): ابدأ بـ'o' مستديرة وانزلق إلى 'إي'.",
    ),
    'ɔɪ': const ArticulationTip(
      "The 'oy' glide (as in 'boy'): start with a rounded 'o' and glide to "
          "'ee'.",
      "صوت 'أوي' (مثل 'boy'): ابدأ بـ'o' مستديرة وانزلق إلى 'إي'.",
    ),
    'er': const ArticulationTip(
      "The 'r' vowel (as in 'bird'): keep the tongue relaxed and curl the tip "
          'back without touching anything, lips neutral.',
      "صوت 'ر' الصوتي (مثل 'bird'): أرخِ لسانك ولوّن طرفه نحو الخلف دون لمس أي شيء، والشفتان متعادلتان.",
    ),
    'ɜː': const ArticulationTip(
      "The 'r' vowel (as in 'bird'): keep the tongue relaxed and curl the tip "
          'back without touching anything, lips neutral.',
      "صوت 'ر' الصوتي (مثل 'bird'): أرخِ لسانك ولوّن طرفه نحو الخلف دون لمس أي شيء، والشفتان متعادلتان.",
    ),
    'ɜ': const ArticulationTip(
      "The 'r' vowel (as in 'bird'): keep the tongue relaxed and curl the tip "
          'back without touching anything, lips neutral.',
      "صوت 'ر' الصوتي (مثل 'bird'): أرخِ لسانك ولوّن طرفه نحو الخلف دون لمس أي شيء، والشفتان متعادلتان.",
    ),

    // Consonants
    'p': const ArticulationTip(
      "Close your lips, build a little pressure, then release with a small "
          'puff of air. Do not use your voice.',
      "أغلق شفتيك، اجمع القليل من الهواء ثم أطلقه بدفعة صغيرة دون استخدام الصوت.",
    ),
    'b': const ArticulationTip(
      "Same lip position as 'p' but with your voice on — your lips vibrate "
          'when the air is released.',
      "نفس وضع شفتَي 'p' لكن مع تشغيل الصوت — تهتزّ شفتاك عند إطلاق الهواء.",
    ),
    't': const ArticulationTip(
      "Touch the tip of your tongue behind your upper front teeth, keep your "
          'voice off, then release with a sharp breath.',
      "ضع طرف لسانك خلف أسنانك الأمامية العلوية، أطفئ صوتك ثم أطلق نفَساً حاداً.",
    ),
    'd': const ArticulationTip(
      "Same tongue position as 't' but with your voice on — press the tongue "
          'to the ridge and release.',
      "نفس وضع لسان 't' لكن مع تشغيل الصوت — اضغط اللسان على الحافّة ثم أطلقه.",
    ),
    'k': const ArticulationTip(
      "Press the back of your tongue against the soft palate (deep in the "
          'mouth) and release with air, voice off.',
      "اضغط مؤخرة لسانك على سقف الحلق ثم أطلقه بدفعة هواء دون صوت.",
    ),
    'g': const ArticulationTip(
      "Same position as 'k' but with your voice on — let the back of the "
          'tongue vibrate against the palate.',
      "نفس وضع 'k' لكن مع تشغيل الصوت — دع مؤخرة اللسان تهتزّ على سقف الحلق.",
    ),
    'f': const ArticulationTip(
      "Rest your bottom lip lightly on your upper teeth and blow air out. No "
          'voice.',
      "ضع شفتك السفلية على أسنانك العلوية وانفخ الهواء دون صوت.",
    ),
    'v': const ArticulationTip(
      "Same lip position as 'f' but with your voice on — feel the vibration "
          'on the lip.',
      "نفس وضع شفة 'f' لكن مع الصوت — أحسّ بالاهتزاز على الشفة.",
    ),
    'th': const ArticulationTip(
      "Place the very tip of your tongue lightly between your front teeth and "
          'blow air out, voice off. Do not bite down.',
      "ضع رأس لسانك برفق بين أسنانك الأمامية وانفخ الهواء دون صوت، ولا تعضّ.",
    ),
    'θ': const ArticulationTip(
      "Place the very tip of your tongue lightly between your front teeth and "
          'blow air out, voice off. Do not bite down.',
      "ضع رأس لسانك برفق بين أسنانك الأمامية وانفخ الهواء دون صوت، ولا تعضّ.",
    ),
    'dh': const ArticulationTip(
      "Same position as 'th' but with your voice on — the tongue stays "
          'between the teeth and vibrates.',
      "نفس وضع 'th' لكن مع تشغيل الصوت — يبقى اللسان بين الأسنان ويهتزّ.",
    ),
    'ð': const ArticulationTip(
      "Same position as 'th' but with your voice on — the tongue stays "
          'between the teeth and vibrates.',
      "نفس وضع 'th' لكن مع تشغيل الصوت — يبقى اللسان بين الأسنان ويهتزّ.",
    ),
    's': const ArticulationTip(
      "Bring your tongue close to the ridge behind your teeth and push a thin "
          'stream of air through the narrow gap, voice off.',
      "قرّب لسانك من الحافّة خلف الأسنان وادفع تياراً رفيعاً من الهواء عبر الفجوة الضيقة دون صوت.",
    ),
    'z': const ArticulationTip(
      "Same position as 's' but with your voice on — you should feel a "
          'buzzing vibration.',
      "نفس وضع 's' لكن مع الصوت — يجب أن تحسّ بالاهتزاز.",
    ),
    'sh': const ArticulationTip(
      "Round your lips slightly forward, flatten your tongue, and blow a "
          'broad stream of air, voice off.',
      "مدّد شفتيك قليلاً للأمام، افرد لسانك، وانفخ تياراً عريضاً من الهواء دون صوت.",
    ),
    'ʃ': const ArticulationTip(
      "Round your lips slightly forward, flatten your tongue, and blow a "
          'broad stream of air, voice off.',
      "مدّد شفتيك قليلاً للأمام، افرد لسانك، وانفخ تياراً عريضاً من الهواء دون صوت.",
    ),
    'zh': const ArticulationTip(
      "Same rounded-lip position as 'sh' but with your voice on (like the "
          "middle sound of 'pleasure').",
      "نفس وضع 'sh' مع الشفاه المستديرة لكن مع الصوت (مثل صوت 'ج' الفرنسية).",
    ),
    'ʒ': const ArticulationTip(
      "Same rounded-lip position as 'sh' but with your voice on (like the "
          "middle sound of 'pleasure').",
      "نفس وضع 'sh' مع الشفاه المستديرة لكن مع الصوت (مثل صوت 'ج' الفرنسية).",
    ),
    'hh': const ArticulationTip(
      "Simply breathe out audibly with the mouth open — it is a voiceless "
          'puff of air, like fogging a window.',
      "ازفر بمسموعية وفمك مفتوح — إنه هواء بلا صوت، مثل إضباب زجاج.",
    ),
    'h': const ArticulationTip(
      "Simply breathe out audibly with the mouth open — it is a voiceless "
          'puff of air, like fogging a window.',
      "ازفر بمسموعية وفمك مفتوح — إنه هواء بلا صوت، مثل إضباب زجاج.",
    ),
    'ch': const ArticulationTip(
      "Start with the tongue tip on the ridge (as for 't') then release to "
          "the broad 'sh' airflow, voice off.",
      "ابدأ بطرف اللسان على الحافّة (كما في 't') ثم أطلقه إلى تدفق 'ش' العريض دون صوت.",
    ),
    'tʃ': const ArticulationTip(
      "Start with the tongue tip on the ridge (as for 't') then release to "
          "the broad 'sh' airflow, voice off.",
      "ابدأ بطرف اللسان على الحافّة (كما في 't') ثم أطلقه إلى تدفق 'ش' العريض دون صوت.",
    ),
    'jh': const ArticulationTip(
      "Start as 'ch' but with the voice on, like the 'j' in 'judge'.",
      "ابدأ كما في 'ch' لكن مع الصوت، مثل 'ج' بالإنجليزية.",
    ),
    'dʒ': const ArticulationTip(
      "Start as 'ch' but with the voice on, like the 'j' in 'judge'.",
      "ابدأ كما في 'ch' لكن مع الصوت، مثل 'ج' بالإنجليزية.",
    ),
    'm': const ArticulationTip(
      "Close your lips and let the sound come through your nose. Keep your "
          'voice on.',
      "أغلق شفتيك ودع الصوت يخرج من أنفك مع إبقاء الصوت في حلقك.",
    ),
    'n': const ArticulationTip(
      "Touch the tongue tip to the ridge behind your teeth and let the sound "
          'come through your nose, voice on.',
      "ضع طرف لسانك خلف الأسنان ودع الصوت يخرج من أنفك مع تشغيل الصوت.",
    ),
    'ng': const ArticulationTip(
      "Press the back of your tongue against the soft palate and let the "
          'sound come through your nose, voice on.',
      "اضغط مؤخرة لسانك على سقف الحلق ودع الصوت يخرج من أنفك مع تشغيل الصوت.",
    ),
    'ŋ': const ArticulationTip(
      "Press the back of your tongue against the soft palate and let the "
          'sound come through your nose, voice on.',
      "اضغط مؤخرة لسانك على سقف الحلق ودع الصوت يخرج من أنفك مع تشغيل الصوت.",
    ),
    'l': const ArticulationTip(
      "Touch the tip of your tongue to the ridge behind your teeth, let the "
          'sides of the tongue stay open, and keep your voice on.',
      "ضع طرف لسانك خلف أسنانك، أبقِ جانبي اللسان مفتوحين، وحافظ على الصوت.",
    ),
    'r': const ArticulationTip(
      "Curl the tip of your tongue back toward the middle of the palate "
          'without touching it, and round your lips slightly.',
      "لوِّن طرف لسانك نحو منتصف الحلق دون لمسه، واستدر شفتيك قليلاً.",
    ),
    'ɹ': const ArticulationTip(
      "Curl the tip of your tongue back toward the middle of the palate "
          'without touching it, and round your lips slightly.',
      "لوِّن طرف لسانك نحو منتصف الحلق دون لمسه، واستدر شفتيك قليلاً.",
    ),
    'w': const ArticulationTip(
      "Tightly round your lips as if saying 'oo', then quickly glide into the "
          'next vowel with your voice on.',
      "دوّر شفتيك بإحكام كأنك تقول 'أو' ثم انزلق بسرعة إلى الصوت التالي مع الصوت.",
    ),
    'y': const ArticulationTip(
      "Raise the front of your tongue close to the palate as if saying 'ee', "
          'then glide quickly into the next vowel.',
      "ارفع مقدمة لسانك قرب الحلق كما في 'إي' ثم انزلق سريعاً إلى الصوت التالي.",
    ),
  };

  static List<String> aliasFor(String phone) => [phone.toLowerCase()];

  static ArticulationTip? forPhone(String phone) => _tips[phone.toLowerCase()];
}
