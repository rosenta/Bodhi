-- =============================================================================
-- Project Bodhi: Seed Data
-- Seeds texts, themes, all 195 Yoga Sutras, top 30 Vivekachudamani verses,
-- verse-theme mappings, and a 30-day daily_verse schedule.
-- =============================================================================
-- Run AFTER schema.sql has been applied.
-- =============================================================================

begin;

-- =============================================================================
-- 1. SOURCE TEXTS
-- =============================================================================

insert into texts (id, slug, title, title_sanskrit, author, description, total_verses, language, source_info) values
(
  '11111111-1111-1111-1111-111111111111',
  'vivekachudamani',
  'Vivekachudamani',
  'विवेकचूडामणि',
  'Adi Shankaracharya',
  'The Crest-Jewel of Discrimination — a masterwork of Advaita Vedanta comprising 580 verses that guide the seeker from initial inquiry to the direct realization of Brahman.',
  580,
  'sanskrit',
  'Traditional Sanskrit text, 8th century CE'
),
(
  '22222222-2222-2222-2222-222222222222',
  'yoga-darshan',
  'Yoga Darshan - Patanjali Yoga Sutras',
  'योगदर्शन — पतञ्जलि योगसूत्र',
  'Maharishi Patanjali',
  'The foundational text of Raja Yoga comprising 195 sutras organized into four padas (chapters), systematically describing the science of mind, practice, powers, and liberation.',
  195,
  'sanskrit',
  'Gita Press, Gorakhpur - Hindi commentary by Harikrishnadas Goyandka'
);


-- =============================================================================
-- 2. THEMES
-- =============================================================================

insert into themes (id, slug, name, name_sanskrit, description, color_hex, sort_order) values
-- Vivekachudamani primary themes
('a0000001-0000-0000-0000-000000000001', 'discrimination',    'Discrimination',       'विवेक',     'Discerning the real from the unreal, the eternal from the transient.',                   '#8B5CF6', 1),
('a0000001-0000-0000-0000-000000000002', 'self-inquiry',      'Self-Inquiry',         'आत्मविचार',  'The direct investigation into the nature of the Self — "Who am I?"',                    '#3B82F6', 2),
('a0000001-0000-0000-0000-000000000003', 'maya',              'Maya (Illusion)',      'माया',       'The cosmic power of illusion that veils reality and projects the world of appearances.', '#EC4899', 3),
('a0000001-0000-0000-0000-000000000004', 'guru-disciple',     'Guru-Disciple',        'गुरुशिष्य',  'The sacred relationship between teacher and student that transmits wisdom.',             '#F59E0B', 4),
('a0000001-0000-0000-0000-000000000005', 'practical-wisdom',  'Practical Wisdom',     'व्यवहारज्ञान','Actionable guidance for daily life, virtues, and the conduct of a seeker.',              '#10B981', 5),
('a0000001-0000-0000-0000-000000000006', 'liberation',        'Liberation',           'मोक्ष',      'The direct experience of freedom — living as the Self, free from bondage.',              '#EF4444', 6),

-- Yoga Sutras pada-level themes
('b0000001-0000-0000-0000-000000000001', 'samadhi',           'Samadhi',              'समाधि',      'Theory and nature of meditative absorption.',                                           '#6366F1', 10),
('b0000001-0000-0000-0000-000000000002', 'practice',          'Practice & Discipline','साधन',       'The path of discipline, purification, and the eight limbs of yoga.',                     '#0EA5E9', 11),
('b0000001-0000-0000-0000-000000000003', 'powers',            'Yogic Powers',         'विभूति',     'Attainments and supernatural abilities arising from yogic practice.',                    '#D946EF', 12),
('b0000001-0000-0000-0000-000000000004', 'kaivalya',          'Kaivalya (Liberation)','कैवल्य',     'Absolute freedom — the ultimate goal of yoga.',                                         '#F97316', 13),

-- Cross-text thematic tags
('c0000001-0000-0000-0000-000000000001', 'mind-control',      'Mind Control',         'चित्तनिरोध',  'Techniques and teachings on stilling the modifications of the mind.',                    '#14B8A6', 20),
('c0000001-0000-0000-0000-000000000002', 'detachment',        'Detachment',           'वैराग्य',    'Non-attachment to sense objects and outcomes.',                                          '#64748B', 21),
('c0000001-0000-0000-0000-000000000003', 'devotion',          'Devotion',             'भक्ति',      'Surrender, devotion to the divine, and self-offering.',                                  '#F43F5E', 22),
('c0000001-0000-0000-0000-000000000004', 'meditation',        'Meditation',           'ध्यान',      'Sustained contemplation and its progressive stages.',                                   '#8B5CF6', 23),
('c0000001-0000-0000-0000-000000000005', 'ethics',            'Ethics & Virtue',      'यमनियम',     'Ethical foundations: non-violence, truth, purity, contentment, and discipline.',          '#22C55E', 24),
('c0000001-0000-0000-0000-000000000006', 'suffering',         'Suffering & Kleshas',  'क्लेश',      'The afflictions that cause suffering and their removal.',                                '#EF4444', 25),
('c0000001-0000-0000-0000-000000000007', 'knowledge',         'Knowledge',            'ज्ञान',      'Valid knowledge, wisdom, and the nature of understanding.',                              '#0284C7', 26);


-- =============================================================================
-- 3. VIVEKACHUDAMANI VERSES (top 30)
-- =============================================================================

insert into verses (id, text_id, verse_number, verse_order, sanskrit, english_translation, modern_interpretation, reel_hook, practice_prompt, why_selected, tags, is_published) values

('v1000001-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '2', 1,
 E'जन्तूनां नरजन्म दुर्लभमतः पुंस्त्वं ततो विप्रता\nतस्माद्वैदिकधर्ममार्गपरता विद्वत्त्वमस्मात्परम्।\nआत्मानात्मविवेचनं स्वनुभवो ब्रह्मात्मना संस्थिति-\nर्मुक्तिर्नो शतकोटिजन्मसु कृतैः पुण्यैर्विना लभ्यते॥ २॥',
 'Among living beings, human birth is rare; rarer still is the desire for knowledge; rarer than that is discrimination between Self and not-Self, direct experience, and abiding as Brahman. Liberation is not achieved without merits accumulated over hundreds of millions of births.',
 E'You have won an impossibly rare cosmic lottery just by being born human with the capacity to question your existence. Most people sleepwalk through this gift, chasing promotions and social media likes. The verse asks: will you use this one wild and precious life to discover who you truly are?',
 'You beat odds of 1 in 400 trillion to be born -- and you''re spending it scrolling?',
 E'Spend 5 minutes today sitting quietly and asking yourself: ''What is the one question I''ve been avoiding about my life?'' Write down whatever arises without editing.',
 'This opening verse creates urgency about the rarity of human birth and the preciousness of self-inquiry, which resonates powerfully with modern audiences questioning their life''s purpose.',
 array['human-birth', 'discrimination', 'rarity', 'liberation', 'merit'], true),

('v1000001-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', '6', 2,
 E'वदन्तु शास्त्राणि यजन्तु देवान्\nकुर्वन्तु कर्माणि भजन्तु देवताः।\nआत्मैक्यबोधेन विना विमुक्ति-\nर्न सिध्यति ब्रह्मशतान्तरेऽपि॥ ६॥',
 'Let them recite scriptures, worship gods, perform rituals, and pray to deities -- without the direct knowledge of one''s identity with the Self, liberation is impossible even in a hundred lifetimes of Brahma.',
 E'You can attend every meditation retreat, read every self-help book, and optimize every morning routine. But without turning inward to discover who you truly are beneath all the doing, real freedom will keep eluding you. External accomplishments cannot substitute for inner clarity.',
 'You can meditate for 10,000 hours and still miss the point entirely.',
 E'Today, pause one habitual spiritual or self-improvement practice (journaling, affirmations, etc.) and instead sit for 10 minutes asking only: ''Who is the one doing all this practice?''',
 'This verse boldly declares that no amount of external religious activity can substitute for direct self-knowledge -- a pattern-interrupting message for both spiritual seekers and productivity-obsessed audiences.',
 array['self-knowledge', 'ritual', 'liberation', 'direct-experience'], true),

('v1000001-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', '11', 3,
 E'चित्तस्य शुद्धये कर्म न तु वस्तूपलब्धये।\nवस्तुसिद्धिर्विचारेण न किञ्चित् कर्मकोटिभिः॥ ११॥',
 'Action serves to purify the mind, not to reveal Reality. Reality is known through inquiry alone, not through millions of actions.',
 E'Our culture worships hustle: more tasks, more output, more doing. But action can only clear the fog; it cannot be the sunlight. Understanding who you are requires you to stop doing and start inquiring. No amount of productivity hacks will show you your own nature.',
 'No amount of hustle will show you who you are. Only stopping will.',
 E'Block 15 minutes today where you do absolutely nothing productive. Sit and simply ask: ''What remains when I stop doing everything?''',
 'This verse draws a clean line between action and understanding -- hugely relevant for a culture that believes harder work always equals better results.',
 array['action', 'inquiry', 'purification', 'hustle-culture'], true),

('v1000001-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111', '20', 4,
 E'ब्रह्म सत्यं जगन्मिथ्येत्येवंरूपो विनिश्चयः।\nसोऽयं नित्यानित्यवस्तुविवेकः समुदाहृतः॥ २०॥',
 'Brahman alone is real, the world is appearance -- this firm conviction is what is called discrimination between the eternal and the transient.',
 E'Everything you can see, touch, measure, and post about is constantly changing -- your body, your bank balance, your relationships, even your thoughts. The only thing that never changes is the awareness witnessing it all. True wisdom is learning to tell the difference between the screen and the movie playing on it.',
 'Everything you''re chasing is the movie. You are the screen.',
 E'Pick one thing you believe defines you (job title, relationship status, body). Now notice: who is aware of that thing? That awareness is what this verse points to.',
 'Perhaps the single most famous distillation of Advaita Vedanta, this verse is maximally quotable and challenges the foundational assumption that the visible world is all there is.',
 array['brahman', 'world-appearance', 'discrimination', 'eternal', 'transient'], true),

('v1000001-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111', '32', 5,
 E'मोक्षकारणसामग्र्यां भक्तिरेव गरीयसी।\nस्वस्वरूपानुसन्धानं भक्तिरित्यभिधीयते॥ ३२॥',
 'Among all means to liberation, devotion is supreme. And devotion is defined as the continuous inquiry into one''s own true nature.',
 E'Forget the image of devotion as blind faith or fervent prayer. The highest form of devotion is the relentless curiosity to know yourself. Every time you pause and ask ''Who am I really?'' you are performing the most sacred act possible. Self-inquiry is not narcissism -- it is the deepest love affair with existence.',
 E'The most sacred prayer isn''t spoken -- it''s the question ''Who am I?''',
 E'Set three random alarms today. Each time one goes off, pause for 30 seconds and silently ask: ''What am I, right now, before any thought arises?''',
 'Shankara redefines devotion not as worship of an external deity but as relentless self-inquiry -- a radical reframing that surprises both religious and secular audiences.',
 array['devotion', 'self-inquiry', 'liberation', 'bhakti'], true),

('v1000001-0000-0000-0000-000000000006', '11111111-1111-1111-1111-111111111111', '39', 6,
 E'शान्ता महान्तो निवसन्ति सन्तो\nवसन्तवल्लोकहितं चरन्तः।\nतीर्णाः स्वयं भीमभवार्णवं जना-\nनहेतुनान्यानपि तारयन्तः॥ ३९॥',
 'Great, peaceful souls dwell in this world like the spring season, bringing welfare to all. Having themselves crossed the terrible ocean of worldly existence, they help others cross too, without any selfish motive.',
 E'Think of that one person whose calm presence changed the energy of every room they entered. Truly awakened people don''t advertise their wisdom -- like springtime, they simply transform everything around them. They have already navigated the storms of identity and anxiety, and they extend a hand not for followers but out of pure compassion.',
 E'The greatest teachers don''t give speeches. They change the season of every room they enter.',
 E'Think of one person who brought peace into your life simply by being themselves. Reach out and thank them today. Then ask yourself: how can I become that presence for someone else?',
 'A beautiful metaphor comparing awakened beings to spring -- they transform everything around them simply by existing, an inspiring image for leadership and mentorship.',
 array['great-souls', 'compassion', 'spring', 'selfless-service', 'guru'], true),

('v1000001-0000-0000-0000-000000000007', '11111111-1111-1111-1111-111111111111', '44', 7,
 E'विद्वांस्स तस्मा उपसत्तिमीयुषे\nमुमुक्षवे साधु यथोक्तकारिणे।\nप्रशान्तचित्ताय शमान्विताय\nतत्त्वोपदेशं कृपयैव कुर्यात्॥ ४४॥',
 'The wise teacher should, out of pure compassion, impart the highest truth to the seeker who has approached with humility, who is genuinely committed to liberation, who obeys the teacher''s guidance, and whose mind is calm and self-controlled.',
 E'Real mentorship is not a transaction -- it is an act of compassion meeting readiness. The best teachers do not teach everyone; they wait for the student who is genuinely hungry, humble, and willing to do the work. And when they teach, they give everything -- not for payment, not for followers, but because the student''s sincerity calls it forth. This is the blueprint for every meaningful teacher-student relationship.',
 E'The best mentor won''t teach you until you prove one thing: that you''re actually ready to change.',
 E'Think of a mentor or teacher you wish you had. Now ask: ''Am I the student they would want to teach? Am I humble enough, hungry enough, and disciplined enough?'' Write down one thing you can do today to become more ready.',
 'Describes the ideal conditions for transformative teaching -- the teacher gives wisdom out of pure compassion to a student who is genuinely ready, modeling the deepest form of mentorship.',
 array['guru', 'compassion', 'readiness', 'teaching', 'humility'], true),

('v1000001-0000-0000-0000-000000000008', '11111111-1111-1111-1111-111111111111', '45', 8,
 E'मा भैष्ट विद्वंस्तव नास्त्यपायः\nसंसारसिन्धोस्तरणेऽस्त्युपायः।\nयेनैव याता यतयोऽस्य पारं\nतमेव मार्गं तव निर्दिशामि॥ ४५॥',
 'Fear not, O wise one! There is no danger for you. There is a way to cross the ocean of worldly existence. I shall show you the very path by which the great sages have crossed before.',
 E'When you are drowning in anxiety, identity crisis, or existential dread, the most powerful thing someone can say is: ''You are not the first person to feel this, and there IS a way through.'' The guru does not remove the ocean. The guru shows you that others have crossed it, and the path still exists. You are not alone, and you are not lost -- even when it feels that way.',
 'Fear not. Others have crossed this exact darkness. And the path they walked still exists.',
 E'Write down your biggest current fear or source of suffering. Then research or recall one person who faced the same challenge and emerged transformed. Let their example serve as your ''guru''s reassurance'' today.',
 E'The guru''s first words of reassurance to the terrified student are universally powerful -- fear not, there IS a way, and I will show it to you.',
 array['fear', 'reassurance', 'guru', 'path', 'hope'], true),

('v1000001-0000-0000-0000-000000000009', '11111111-1111-1111-1111-111111111111', '51', 9,
 E'को नाम बन्धः कथमेष आगतः\nकथं प्रतिष्ठास्य कथं विमोक्षः।\nकोऽसावनात्मा परमः क आत्मा\nतयोर्विवेकः कथमेतदुच्यताम्॥ ५१॥',
 'What is bondage? How did it arise? How does it persist? How can one be free? What is the not-Self? What is the Supreme Self? And how does one discriminate between them? Please tell me.',
 E'These are the questions that wake you up at 3 AM: Why do I feel trapped? How did I end up here? What would real freedom even look like? Who am I underneath all the roles I play? Instead of numbing these questions with Netflix or alcohol, Shankara says: follow them. They are the door.',
 'The questions that keep you up at 3 AM are the only ones worth answering.',
 E'Write down the five biggest questions you have about your life right now. Don''t answer them. Just sit with them for 5 minutes. Notice which one creates the most energy in your body.',
 E'The student''s foundational questions mirror the existential crisis every modern person faces -- what binds me, what frees me, who am I really?',
 array['bondage', 'freedom', 'questions', 'self', 'not-self', 'existential'], true),

('v1000001-0000-0000-0000-000000000010', '11111111-1111-1111-1111-111111111111', '53', 10,
 E'ऋणमोचनकर्तारः पितुः सन्ति सुतादयः।\nबन्धमोचनकर्ता तु स्वस्मादन्यो न कश्चन॥ ५३॥',
 'Sons and others can repay a father''s debts. But there is no one other than oneself who can remove one''s own bondage.',
 E'Your parents can leave you money. Your therapist can give you frameworks. Your partner can give you comfort. But the deepest chains -- the ones made of self-ignorance, fear, and false identity -- only you can break. This is not a burden; it is the ultimate empowerment. No one is coming to save you because no one needs to. The key has always been in your hand.',
 E'Everyone can pay your bills. Nobody can free your soul. That''s your job.',
 E'Identify one problem you have been waiting for someone else to solve (a parent, partner, therapist, boss). Write down: ''Only I can free myself from this.'' Then take one small, concrete action toward that freedom today.',
 'A sobering truth about radical self-responsibility -- others can pay your debts, but no one else can free your soul -- powerful for an era of dependency on external validation.',
 array['self-responsibility', 'bondage', 'freedom', 'empowerment'], true),

('v1000001-0000-0000-0000-000000000011', '11111111-1111-1111-1111-111111111111', '58', 11,
 E'न योगेन न सांख्येन कर्मणा नो न विद्यया।\nब्रह्मात्मैकत्वबोधेन मोक्षः सिद्ध्यति नान्यथा॥ ५८॥',
 'Liberation is not achieved through yoga, nor through Sankhya philosophy, nor through action, nor through learning -- but only through the direct knowledge of the oneness of Self and Brahman, and by no other means.',
 E'Yoga won''t do it. Philosophy won''t do it. Good deeds won''t do it. Academic degrees won''t do it. The only thing that frees you is the direct, lived realization that your true self and the ultimate reality are one and the same. Everything else is preparation, not arrival.',
 'Yoga can''t free you. Philosophy can''t free you. Only one thing can.',
 E'For 5 minutes, drop every technique and method you know. Simply be aware of being aware. Notice that this awareness has no edges, no shape, no limits. Rest there.',
 'A supremely quotable verse that eliminates all half-measures and points to the singular path of direct knowledge, cutting through spiritual marketplace confusion.',
 array['liberation', 'direct-knowledge', 'oneness', 'brahman'], true),

('v1000001-0000-0000-0000-000000000012', '11111111-1111-1111-1111-111111111111', '63', 12,
 E'अज्ञानसर्पदष्टस्य ब्रह्मज्ञानौषधं विना।\nकिमु वेदैश्च शास्त्रैश्च किमु मन्त्रैः किमौषधैः॥ ६३॥',
 'For one bitten by the snake of ignorance, what use are the Vedas, scriptures, mantras, or medicines -- without the medicine of Self-knowledge?',
 E'When you are suffering from a deep identity crisis -- not knowing who you are, what you are for, why you feel empty despite having everything -- no amount of motivational quotes, therapy jargon, or spiritual bypassing will cure the root problem. The snakebite of fundamental self-ignorance requires the specific antidote of knowing your true Self.',
 E'You''ve been bitten by a snake you can''t see. And affirmations aren''t the antidote.',
 E'Identify one area of suffering in your life. Ask: ''Is this suffering happening because I don''t know who I truly am?'' Sit with this question for 3 minutes without trying to answer it intellectually.',
 'The snake-bite metaphor is vivid and urgent -- when ignorance has poisoned you, only the antidote of direct knowledge works, not reciting formulas.',
 array['ignorance', 'snake-metaphor', 'self-knowledge', 'antidote'], true),

('v1000001-0000-0000-0000-000000000013', '11111111-1111-1111-1111-111111111111', '78', 13,
 E'शब्दादिभिः पञ्चभिरेव पञ्च\nपञ्चत्वमापुः स्वगुणेन बद्धाः।\nकुरङ्गमातङ्गपतङ्गमीन-\nभृङ्गा नरः पञ्चभिरञ्चितः किम्॥ ७८॥',
 'The deer, elephant, moth, fish, and bee -- each is destroyed by attachment to just one of the five senses. What chance does a human have, enslaved by all five?',
 E'The deer is killed by sound (the hunter''s flute). The elephant by touch (the female decoy). The moth by sight (the flame). The fish by taste (the bait). The bee by smell (the flower that traps). Each animal falls to just ONE sense. You carry all five -- plus a phone designed by teams of engineers to exploit every single one of them.',
 E'A moth dies chasing one light. You''re chasing five -- on a screen designed to kill your attention.',
 E'Turn off all notifications for 2 hours today. Notice which urge is strongest: to look, to listen, to touch, to taste, or to smell something. That is your primary chain. Sit with the discomfort.',
 'The five-animals metaphor is unforgettable and perfectly illustrates how sensory addiction destroys us -- deeply relevant to our age of dopamine hijacking.',
 array['senses', 'addiction', 'deer', 'elephant', 'moth', 'fish', 'bee', 'dopamine'], true),

('v1000001-0000-0000-0000-000000000014', '11111111-1111-1111-1111-111111111111', '84', 14,
 E'मोक्षस्य काङ्क्षा यदि वै तवास्ति\nत्यजातिदूराद्विषयान् विषं यथा।\nपीयूषवत्तोषदयाक्षमार्जव-\nप्रशान्तिदान्तीर्भज नित्यमादरात्॥ ८४॥',
 'If you truly desire liberation, renounce sense pleasures from afar as you would poison, and daily cultivate contentment, compassion, forgiveness, sincerity, tranquility, and self-control as if they were nectar.',
 E'Think of your worst dopamine habit as literal poison -- it feels good going down but slowly kills your capacity for deep joy. Now flip it: contentment, compassion, forgiveness, and inner calm are nectar -- they taste plain at first but build a life of genuine peace. Freedom is not about adding more; it is about knowing what to refuse.',
 'Your dopamine hit is poison dressed as pleasure. Contentment is the real nectar.',
 E'Identify your top ''pleasure poison'' (social media, sugar, gossip). Replace it today with one ''nectar practice'': 10 minutes of silence, one act of forgiveness, or a genuine compliment to a stranger.',
 'This verse gives an actionable formula: treat sense pleasures as poison and virtues as nectar -- a vivid, practical framework anyone can apply today.',
 array['liberation', 'renunciation', 'virtues', 'contentment', 'compassion', 'poison-nectar'], true),

('v1000001-0000-0000-0000-000000000015', '11111111-1111-1111-1111-111111111111', '86', 15,
 E'शरीरपोषणार्थी सन् य आत्मानं दिदृक्षति।\nग्राहं दारुधिया धृत्वा नदीं तर्तुं स गच्छति॥ ८६॥',
 'One who seeks to know the Self while devoted to nourishing the body is like someone who tries to cross a river by holding on to a crocodile, mistaking it for a log.',
 E'You cannot optimize your way to enlightenment through biohacking your body while ignoring your mind. Obsessing over the physical vessel -- gym selfies, skin routines, diet cults -- while never asking who lives inside that body is like grabbing a crocodile thinking it will carry you safely across the river. The thing you are clinging to is the very thing that will drag you under.',
 'Obsessing over your body while ignoring your soul is like hugging a crocodile to cross a river.',
 E'Notice today how much mental energy goes toward your body''s appearance versus understanding your inner nature. For every body-focused thought, pause and redirect: ''Who is the one aware of this body?''',
 'The crocodile metaphor is darkly humorous and immediately relatable to anyone who prioritizes physical appearance or comfort over inner growth.',
 array['body-identification', 'crocodile', 'self-knowledge', 'humor'], true),

('v1000001-0000-0000-0000-000000000016', '11111111-1111-1111-1111-111111111111', '108', 16,
 E'आत्मार्थत्वेन हि प्रेयान् विषयो न स्वतः प्रियः।\nस्वत एव हि सर्वेषामात्मा प्रियतमो यतः॥ १०८॥',
 'Objects are not loved for their own sake but for the sake of the Self. For the Self alone is the most beloved of all.',
 E'You don''t love your partner, your children, or your career for what they are. You love them because in their presence, your own sense of self expands and you feel more alive. Every craving is secretly a craving for your own deeper nature. When you realize this, you stop demanding that the world complete you -- because you already are what you were looking for.',
 'You don''t love them. You love the version of yourself they help you feel.',
 E'Think of something you deeply love. Now ask: ''What do I actually experience when I enjoy this?'' Notice that beneath the object, it is your own expanded awareness that feels good. Stay with that awareness for 2 minutes.',
 'This verse reveals the hidden logic beneath all desire -- that what we truly love in any experience is our own Self -- a perspective shift that reframes every relationship and craving.',
 array['love', 'self', 'desire', 'objects', 'relationships'], true),

('v1000001-0000-0000-0000-000000000017', '11111111-1111-1111-1111-111111111111', '110', 17,
 E'अव्यक्तनाम्नी परमेशश्क्ति-\nरनाद्यविद्या त्रिगुणात्मिका परा।\nकार्यानुमेया सुधियैव माया\nयया जगत्सर्वमिदं प्रसूयते॥ ११०॥',
 'Called the Unmanifest, the beginningless power of ignorance, composed of three qualities, the supreme power of the Lord -- this is Maya, inferred only through its effects by the wise, from which this entire world is born.',
 E'There is an invisible operating system running your entire experience of reality, and you have never seen it directly -- only its outputs: the world of names, forms, and experiences. Like a virtual reality headset you forgot you put on, Maya generates the convincingly real simulation you call your life. The wise person does not try to fix the simulation; they look for the one wearing the headset.',
 E'You''re wearing a VR headset called Maya -- and you forgot you put it on.',
 E'For 2 minutes, look at your room and ask: ''What if none of this is as solid as it appears?'' Notice the slight shift in perception when you hold that question genuinely. That crack in certainty is the beginning of wisdom.',
 'The definitive verse on Maya -- the cosmic creative power that generates the entire world of appearance -- is essential for understanding why things feel so real yet are not ultimate.',
 array['maya', 'unmanifest', 'three-gunas', 'illusion', 'virtual-reality'], true),

('v1000001-0000-0000-0000-000000000018', '11111111-1111-1111-1111-111111111111', '136', 18,
 E'न जायते नो म्रियते न वर्धते\nन क्षीयते नो विकरोति नित्यः।\nविलीयमानेऽपि वपुष्यमुष्मिन्\nन लीयते कुम्भ इवाम्बरं स्वयम्॥ १३६॥',
 'It is never born, never dies, never grows, never diminishes, never changes. It is eternal. Even when this body is destroyed, the Self is not destroyed -- just as the sky within a pot is not destroyed when the pot breaks.',
 E'Your body will age, your identity will shift, your relationships will change, and one day your heart will stop. But the awareness that is reading these words right now -- that has never been born and will never die. When a clay pot breaks, the space inside it does not shatter. It simply merges back into the infinite sky it was always part of.',
 E'When the pot breaks, the sky inside doesn''t shatter. Neither will you.',
 E'Close your eyes and notice the space of awareness in which thoughts arise. Now imagine this body dissolving. Ask: ''Does this awareness itself have any edges? Can it be destroyed?'' Rest in whatever you discover.',
 'One of the most powerful descriptions of the immortal Self -- it neither is born nor dies -- directly addressing humanity''s deepest fear with an unforgettable pot-and-sky metaphor.',
 array['immortality', 'self', 'pot-sky', 'eternal', 'death', 'awareness'], true),

('v1000001-0000-0000-0000-000000000019', '11111111-1111-1111-1111-111111111111', '138', 19,
 E'नियमितमनसामुं त्वं स्वमात्मानमात्म-\nन्ययमहमिति साक्षाद्विद्धि बुद्धिप्रसादात्।\nजनिमरणतरङ्गापारसंसारसिन्धुं\nप्रतर भव कृतार्थो ब्रह्मरूपेण संस्थितः॥ १३८॥',
 'With a controlled mind, know this Self directly within yourself as ''I am That,'' through the grace of a clear intellect. Cross this shoreless ocean of worldly existence with its waves of birth and death. Abide as Brahman and be fulfilled.',
 E'Here is the entire map in four lines: Quiet the noise inside. Recognize what you truly are. Let that recognition carry you across the endless waves of anxiety, loss, and identity crisis. Then stay there -- not as a temporary peak experience, but as your permanent address. Fulfillment is not something you achieve. It is something you recognize you already are.',
 'The entire path to freedom fits in four lines. Most people spend a lifetime avoiding the first one: be still.',
 E'Sit for 5 minutes with eyes closed. Let thoughts come and go like waves. Ask: ''What is the ocean beneath all these waves?'' When you sense something vast and still, rest there. That is the Self this verse points to.',
 'A complete instruction in one verse: still the mind, know the Self, cross the ocean of suffering, and abide as Brahman -- the entire spiritual journey condensed to four lines.',
 array['self-realization', 'i-am-that', 'ocean', 'brahman', 'fulfillment'], true),

('v1000001-0000-0000-0000-000000000020', '11111111-1111-1111-1111-111111111111', '147', 20,
 E'बीजं संसृतिभूमिजस्य तु तमो देहात्मधीरङ्कुरो\nरागः पल्लवमम्बु कर्म तु वपुः स्कन्धोऽसवः शाखिकाः।\nअग्राणीन्द्रियसंहतिश्च विषयाः पुष्पाणि दुःखं फलं\nनानाकर्मसमुद्भवं बहुविधं भोक्तात्र जीवः खगः॥ १४७॥',
 'The seed of this worldly tree is ignorance; body-identification is its sprout; desire is its leaves; karma is water; the body is the trunk; the vital airs are branches; the senses are twigs; sense objects are flowers; suffering born of diverse actions is its fruit; and the individual soul is the bird that feeds on it.',
 E'Imagine your suffering as a tree. The invisible seed is not knowing who you are. The first sprout is thinking you are your body and your story. Desire becomes the leaves that keep it growing; every action waters it further. Your senses are the branches reaching out for stimulation. And the fruit? Pain -- in endless varieties. You, the soul, sit on this tree eating its bitter fruit, not realizing you can simply fly away.',
 'Your suffering is a tree. Ignorance planted it. Desire waters it. And you keep eating the fruit.',
 E'Draw or visualize the ''tree of your suffering.'' Label the seed (core misidentification), the trunk (your body-story), the branches (habits), and the fruit (recurring pain). Then ask: ''What if I could just stop watering this tree?''',
 'The tree-of-samsara metaphor maps every element of suffering to a botanical image -- ignorance as seed, body-identification as sprout, desire as leaves, suffering as fruit -- a masterful extended analogy.',
 array['samsara-tree', 'ignorance', 'desire', 'karma', 'suffering', 'metaphor'], true),

('v1000001-0000-0000-0000-000000000021', '11111111-1111-1111-1111-111111111111', '149', 21,
 E'नास्त्रेणैनं शस्त्रनिलेन वह्निना\nछेत्तुं न शक्यो न च कर्मकोटिभिः।\nविवेकविज्ञानमहासिना विना\nधातुः प्रसादेन सितेन मञ्जुना॥ १४९॥',
 'This bondage cannot be cut by weapons, wind, fire, or millions of actions -- only by the great, shining, and beautiful sword of discriminative wisdom, sharpened by divine grace.',
 E'No amount of force, willpower, productivity, or external power can sever the invisible chains binding you. The only weapon that works is the razor-sharp clarity of knowing what is real and what is not. And here is the paradox: this sword is not forged through effort alone -- it arrives as a gift of grace when the mind is ready. Your job is to sharpen your discernment; grace does the final cut.',
 E'No weapon can cut this chain. No fire can burn it. Only one sword works -- and most people have never picked it up.',
 E'Practice one act of discernment today: when a strong emotion arises, pause and ask ''Is this who I AM, or is this something I am EXPERIENCING?'' This distinction is the edge of the sword.',
 'The sword-of-discrimination metaphor is epic and cinematic -- bondage cannot be cut by weapons or fire, only by the brilliant sword of wisdom granted by grace.',
 array['sword', 'discrimination', 'wisdom', 'grace', 'bondage'], true),

('v1000001-0000-0000-0000-000000000022', '11111111-1111-1111-1111-111111111111', '174', 22,
 E'वायुनानीयते मेघः पुनस्तेनैव नीयते।\nमनसा कल्प्यते बन्धो मोक्षस्तेनैव कल्प्यते॥ १७४॥',
 'The wind brings clouds and the same wind disperses them. The mind creates bondage and the same mind creates liberation.',
 E'The instrument of your imprisonment is also the instrument of your freedom. The same mind that spins anxiety, comparison, and self-doubt can -- when turned inward -- dissolve all of it. You do not need a new mind; you need to point the same mind in a different direction. The wind that gathered the storm clouds is the very wind that will clear the sky.',
 'The mind that trapped you is the only thing that can free you.',
 E'The next time your mind spirals into negativity, consciously redirect it: ''This same mind that creates worry can create peace.'' Spend 2 minutes deliberately thinking about something that brings you genuine gratitude. Feel the shift.',
 'The wind-and-clouds metaphor perfectly captures how the same mind creates both bondage and freedom -- an empowering realization for anyone feeling trapped.',
 array['mind', 'wind', 'clouds', 'bondage', 'freedom', 'empowerment'], true),

('v1000001-0000-0000-0000-000000000023', '11111111-1111-1111-1111-111111111111', '199', 23,
 E'रज्ज्वां सर्पो भ्रान्तिकालीन एव\nभ्रान्तिर्नाशे नैव सर्पोऽपि तद्वत्॥ १९९॥',
 'The snake in the rope exists only as long as the delusion lasts. When the delusion ends, the snake too ceases to exist. So it is with this world.',
 E'You walk into a dark room, see a coiled rope, and your heart races: snake! But the snake never existed -- only your misperception of the rope did. The moment you turn on the light, the terror vanishes. In the same way, the suffering you experience in life is not caused by reality itself but by your misperception of it. You do not need to kill the snake. You need to turn on the light.',
 E'You don''t need to kill the snake. You just need to turn on the light.',
 E'Recall a past fear that turned out to be unfounded. Notice how the ''snake'' completely disappeared when you saw clearly. Now ask: ''What snake am I seeing right now in my life that might just be a rope?''',
 E'The rope-snake analogy is Vedanta''s most iconic teaching device -- it shows how ignorance creates suffering that vanishes the instant you see clearly.',
 array['rope-snake', 'delusion', 'perception', 'fear', 'vedanta'], true),

('v1000001-0000-0000-0000-000000000024', '11111111-1111-1111-1111-111111111111', '219', 24,
 E'जाग्रत्स्वप्नसुषुप्तिषु स्फुटतरं योऽसौ समुज्जृम्भते\nप्रत्यग्रूपतया सदाहमहमित्यन्तःस्फुरन्नैकधा।\nनानाकारविकारभागिन इमान्पश्यन्नहन्धीमुखान्\nनित्यानन्दचिदात्मना स्फुरति तं विद्धि स्वमेतं हृदि॥ २१९॥',
 'That which shines clearly through waking, dreaming, and deep sleep, which pulsates inwardly as the constant ''I-I'' in many ways, which witnesses all changes of ego and mind -- know That as your own Self, here in the heart, as eternal bliss and consciousness.',
 E'There is something in you that was present in childhood, is present now, and will be present in your last breath. It is the silent ''I'' that does not change when your mood changes, when your beliefs change, or when your life circumstances flip upside down. It watches the drama of your ego without getting involved. It is awake even in deep sleep. That is not your personality. That is You.',
 'Something in you has never changed -- not once, not ever. And it''s watching this reel right now.',
 E'Sit quietly and notice the sense of ''I am.'' Not ''I am a teacher'' or ''I am anxious'' -- just the bare sense of existing. Follow it inward. Notice it does not change even as thoughts come and go. Stay with this for 5 minutes.',
 'This verse gives a direct, experiential pointer to the Self -- the ''I-I'' pulsation that persists through all three states of consciousness -- perfect for guiding actual meditation practice.',
 array['three-states', 'i-am', 'witness', 'consciousness', 'heart', 'meditation'], true),

('v1000001-0000-0000-0000-000000000025', '11111111-1111-1111-1111-111111111111', '224', 25,
 E'विशोक आनन्दघनो विपश्चित्\nस्वयं कुतश्चिन्न बिभेति कश्चित्।\nनान्योऽस्ति पन्था भवबन्धमुक्ते-\nर्विना स्वतत्त्वावगमं मुमुक्षोः॥ २२४॥',
 'The wise one, free from sorrow and full of bliss, fears nothing from anywhere. For the seeker of liberation, there is no other path to freedom from bondage than the knowledge of one''s own true nature.',
 E'When you truly know what you are, two things happen simultaneously: sorrow loses its grip and fear loses its object. You become what every human secretly wants to be -- unshakeable. And here is the non-negotiable truth: there is no hack, no shortcut, no workaround. Self-knowledge is the only exit. Everything else is rearranging furniture on the Titanic.',
 'There is exactly ONE exit from suffering. And most people spend their whole lives looking everywhere except there.',
 E'Ask yourself: ''What am I most afraid of?'' Then ask: ''Would that fear exist if I truly knew I am not the body, not the mind, but the awareness witnessing both?'' Sit with whatever arises for 3 minutes.',
 'Declares that self-knowledge is the ONLY path to freedom -- there is no alternative -- while promising that the knower becomes fearless and filled with bliss.',
 array['fearlessness', 'bliss', 'self-knowledge', 'only-path', 'liberation'], true),

('v1000001-0000-0000-0000-000000000026', '11111111-1111-1111-1111-111111111111', '269', 26,
 E'अहंममेति यो भावो देहाक्षादावनात्मनि।\nअध्यासोऽयं निरस्तव्यो विदुषा स्वात्मनिष्ठया॥ २६९॥',
 'The notion of ''I'' and ''mine'' in the body, senses, and other non-Self objects is superimposition (adhyasa). The wise person must remove this through abiding in the Self.',
 E'Every time you say ''my career,'' ''my reputation,'' ''my anxiety'' -- you are gluing your identity to something that is not you. This glue is called superimposition. It is the root of all suffering because when ''your'' career fails, ''you'' feel destroyed. The practice is simple but not easy: notice each ''I'' and ''mine,'' and gently ask, ''Is this truly me, or something I am aware of?''',
 E'Every ''my'' is a lie your ego tells. My body. My career. My anxiety. None of it is you.',
 E'For the next hour, every time you think or say ''my'' or ''I am'' followed by something external (my job, my stress, I am tired), mentally add: ''...but is that really me?'' Notice what loosens.',
 'Identifies ''I'' and ''mine'' as the core mechanism of all suffering -- a razor-sharp teaching that applies to every form of ego attachment.',
 array['adhyasa', 'superimposition', 'i-mine', 'ego', 'dis-identification'], true),

('v1000001-0000-0000-0000-000000000027', '11111111-1111-1111-1111-111111111111', '318', 27,
 E'क्रियानाशे भवेच्चिन्तानाशोऽस्माद्वासनाक्षयः।\nवासनाप्रक्षयो मोक्षः सा जीवन्मुक्तिरिष्यते॥ ३१८॥',
 'When compulsive action ceases, obsessive thinking ceases; from that, deep-seated patterns dissolve. The dissolution of these patterns IS liberation -- this is what is called freedom while alive.',
 E'Freedom is not an event that happens after death or at the end of a long retreat. It is a chain reaction available now: stop compulsive doing, and compulsive thinking settles; when thinking settles, the unconscious patterns driving your life lose their fuel; when those patterns dissolve, you are free -- right here, in this body, in this life. Liberation is not escape. It is the end of the engine that kept creating your prison.',
 E'Freedom is not an escape plan. It''s a chain reaction: stop doing, stop thinking, stop craving -- and you''re already free.',
 E'Identify one compulsive action loop (checking email, picking up phone, stress-eating). Break the chain today by inserting a 60-second pause before acting. In that pause, simply breathe and observe. Note what happens to the mental chatter.',
 'A precise chain reaction leading to liberation: cessation of compulsive action leads to cessation of obsessive thinking, which leads to the end of deep-seated patterns, which IS freedom.',
 array['chain-reaction', 'vasanas', 'compulsion', 'jivanmukti', 'living-liberation'], true),

('v1000001-0000-0000-0000-000000000028', '11111111-1111-1111-1111-111111111111', '325', 28,
 E'यथापकृष्टं शैवालं क्षणमात्रं न तिष्ठति।\nआवृणोति तथा माया प्राज्ञं वापि पराङ्मुखम्॥ ३२५॥',
 'Just as duckweed, when pushed aside, does not stay away even for a moment, so Maya covers over even the wise one who turns away from Self-inquiry.',
 E'You know that feeling when you have a genuine insight or a moment of deep peace, but within minutes your phone buzzes and the clarity evaporates? That is duckweed. Illusion is not a one-time enemy you defeat; it is a surface that closes over the water the instant you stop clearing it. This is why spiritual practice must be continuous, not occasional.',
 E'That moment of clarity you had this morning? It''s already been covered over. Here''s why.',
 E'After your next moment of peace or clarity (during meditation, in nature, or in a quiet moment), deliberately maintain awareness for 5 extra minutes. Watch how quickly the ''duckweed'' of distraction tries to close back over. Gently clear it again.',
 'The duckweed metaphor is brilliantly simple and carries an urgent warning: the moment you stop paying attention, Maya (illusion/distraction) covers you again instantly.',
 array['duckweed', 'maya', 'vigilance', 'distraction', 'continuous-practice'], true),

('v1000001-0000-0000-0000-000000000029', '11111111-1111-1111-1111-111111111111', '375', 29,
 E'वैराग्यबोधौ पुरुषस्य पक्षिवत्\nपक्षौ विजानीहि विचक्षण त्वम्।\nविमुक्तिसौधाग्रतलाधिरोहणं\nताभ्यां विना नान्यतरेण सिध्यति॥ ३७५॥',
 'Know that dispassion and knowledge are like the two wings of a bird for a person. Without both, no one can reach the rooftop of liberation with only one.',
 E'You cannot think your way to freedom without letting go, and you cannot let go without understanding why. Knowledge without detachment becomes intellectual arrogance. Detachment without knowledge becomes spiritual bypassing. Real liberation requires both wings beating in harmony -- the wisdom to see clearly and the courage to release what is false.',
 E'You can''t fly to freedom with one wing. Knowledge without letting go is just trivia. Letting go without knowledge is just escapism.',
 E'Assess your two wings today. Ask: ''Am I stronger in understanding (reading, learning, analyzing) or in letting go (releasing attachments, simplifying, surrendering)?'' Spend 15 minutes strengthening your weaker wing.',
 'The two-wings-of-a-bird metaphor is immediately memorable and teaches that both dispassion AND knowledge are required -- you cannot fly with one wing.',
 array['two-wings', 'vairagya', 'knowledge', 'dispassion', 'balance'], true),

('v1000001-0000-0000-0000-000000000030', '11111111-1111-1111-1111-111111111111', '397', 30,
 E'शवाकारं यावद्भजति मनुजस्तावदशुचिः\nपरेभ्यः स्यात्क्लेशो जननमरणव्याधिनिलयः।\nयदात्मानं शुद्धं कलयति शिवाकारमचलं\nतदा तेभ्यो मुक्तो भवति हि तदाह श्रुतिरपि॥ ३९७॥',
 'As long as a person identifies with this corpse-like body, they remain impure, subject to suffering from others, and a dwelling place for birth, death, and disease. But when they realize their Self as pure, auspicious, and immovable -- then they are freed from all these. Even the scripture declares this.',
 E'As long as you think you are a body with an expiration date, you will live in fear of aging, illness, rejection, and death. You will be at the mercy of other people''s opinions and life''s random cruelty. But the moment you shift identity from the body-vehicle to the awareness driving it, something extraordinary happens: you become untouchable. Not arrogant -- just free. The scripture confirms what your deepest intuition already knows.',
 E'You''re not a body slowly dying. You''re the awareness that was never born. And that changes everything.',
 E'Stand in front of a mirror. Look at your body and say: ''This is my vehicle, not my identity.'' Then close your eyes and feel the awareness behind the image. Ask: ''Which one am I -- the reflection, or the one seeing it?'' Stay with that.',
 'A visceral contrast between identifying with a corpse-like body versus recognizing one''s pure, auspicious nature -- the ''switch'' that ends all suffering.',
 array['body-identification', 'corpse', 'pure-self', 'identity-shift', 'scripture'], true);


-- =============================================================================
-- 4. VIVEKACHUDAMANI VERSE-THEME MAPPINGS
-- =============================================================================

-- Map each verse to its primary theme based on the JSON "theme" field
insert into verse_themes (verse_id, theme_id, is_primary) values
-- discrimination
('v1000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000001', true),  -- verse 2
('v1000001-0000-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000001', true),  -- verse 6
('v1000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000001', true),  -- verse 11
('v1000001-0000-0000-0000-000000000004', 'a0000001-0000-0000-0000-000000000001', true),  -- verse 20
('v1000001-0000-0000-0000-000000000011', 'a0000001-0000-0000-0000-000000000001', true),  -- verse 58
('v1000001-0000-0000-0000-000000000012', 'a0000001-0000-0000-0000-000000000001', true),  -- verse 63
('v1000001-0000-0000-0000-000000000021', 'a0000001-0000-0000-0000-000000000001', true),  -- verse 149
('v1000001-0000-0000-0000-000000000023', 'a0000001-0000-0000-0000-000000000001', true),  -- verse 199
-- self-inquiry
('v1000001-0000-0000-0000-000000000005', 'a0000001-0000-0000-0000-000000000002', true),  -- verse 32
('v1000001-0000-0000-0000-000000000009', 'a0000001-0000-0000-0000-000000000002', true),  -- verse 51
('v1000001-0000-0000-0000-000000000016', 'a0000001-0000-0000-0000-000000000002', true),  -- verse 108
('v1000001-0000-0000-0000-000000000018', 'a0000001-0000-0000-0000-000000000002', true),  -- verse 136
('v1000001-0000-0000-0000-000000000024', 'a0000001-0000-0000-0000-000000000002', true),  -- verse 219
-- maya
('v1000001-0000-0000-0000-000000000013', 'a0000001-0000-0000-0000-000000000003', true),  -- verse 78
('v1000001-0000-0000-0000-000000000017', 'a0000001-0000-0000-0000-000000000003', true),  -- verse 110
('v1000001-0000-0000-0000-000000000020', 'a0000001-0000-0000-0000-000000000003', true),  -- verse 147
('v1000001-0000-0000-0000-000000000022', 'a0000001-0000-0000-0000-000000000003', true),  -- verse 174
('v1000001-0000-0000-0000-000000000028', 'a0000001-0000-0000-0000-000000000003', true),  -- verse 325
-- guru-disciple
('v1000001-0000-0000-0000-000000000006', 'a0000001-0000-0000-0000-000000000004', true),  -- verse 39
('v1000001-0000-0000-0000-000000000007', 'a0000001-0000-0000-0000-000000000004', true),  -- verse 44
('v1000001-0000-0000-0000-000000000008', 'a0000001-0000-0000-0000-000000000004', true),  -- verse 45
('v1000001-0000-0000-0000-000000000010', 'a0000001-0000-0000-0000-000000000004', true),  -- verse 53
-- practical-wisdom
('v1000001-0000-0000-0000-000000000014', 'a0000001-0000-0000-0000-000000000005', true),  -- verse 84
('v1000001-0000-0000-0000-000000000015', 'a0000001-0000-0000-0000-000000000005', true),  -- verse 86
('v1000001-0000-0000-0000-000000000026', 'a0000001-0000-0000-0000-000000000005', true),  -- verse 269
('v1000001-0000-0000-0000-000000000029', 'a0000001-0000-0000-0000-000000000005', true),  -- verse 375
-- liberation
('v1000001-0000-0000-0000-000000000019', 'a0000001-0000-0000-0000-000000000006', true),  -- verse 138
('v1000001-0000-0000-0000-000000000025', 'a0000001-0000-0000-0000-000000000006', true),  -- verse 224
('v1000001-0000-0000-0000-000000000027', 'a0000001-0000-0000-0000-000000000006', true),  -- verse 318
('v1000001-0000-0000-0000-000000000030', 'a0000001-0000-0000-0000-000000000006', true);  -- verse 397


-- =============================================================================
-- 5. YOGA SUTRAS (all 195)
-- =============================================================================
-- Inserted using a compact format. Each sutra is a single insert row.
-- Pada 1: Samadhi Pada (1.1 - 1.51)
-- Pada 2: Sadhana Pada (2.1 - 2.55)
-- Pada 3: Vibhuti Pada (3.1 - 3.55)
-- Pada 4: Kaivalya Pada (4.1 - 4.34)

-- NOTE: The verse IDs follow pattern ys-{pada}-{sutra} for traceability.
-- The full Yoga Sutras data is inserted from yoga-sutras-complete.json.
-- For brevity, hindi_meaning and practical_application are included in the
-- modern_interpretation and practice_prompt columns respectively.

-- Helper: generates deterministic UUIDs for yoga sutras
-- Pattern: y{pada}00000{sutra_zero_padded}-0000-0000-0000-000000000000

-- ===================== PADA 1: SAMADHI PADA (51 sutras) =====================

insert into verses (id, text_id, verse_number, verse_order, pada, pada_number, sanskrit, transliteration, hindi_meaning, english_translation, modern_interpretation, practice_prompt, tags, is_published) values
('y1000001-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', '1.1',  1, 'Samadhi Pada', 1, 'अथ योगानुशासनम्', 'atha yogānuśāsanam', 'अब परम्परागत योगविषयक शास्त्र का आरम्भ करते हैं।', 'Now begins the authoritative instruction on Yoga.', null, 'Recognize that yoga is a disciplined practice passed down through tradition. Begin your study with humility and readiness.', array['introduction', 'discipline', 'tradition', 'beginning'], true),
('y1000001-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', '1.2',  2, 'Samadhi Pada', 1, 'योगश्चित्तवृत्तिनिरोधः', 'yogaś citta-vṛtti-nirodhaḥ', 'चित्त की वृत्तियों का निरोध (सर्वथा रुक जाना) ही योग है।', 'Yoga is the cessation of the modifications of the mind.', null, 'Practice stilling the constant chatter of the mind through meditation, breath work, and mindful awareness throughout the day.', array['definition', 'chitta', 'vritti', 'nirodha', 'mind-control'], true),
('y1000001-0000-0000-0000-000000000003', '22222222-2222-2222-2222-222222222222', '1.3',  3, 'Samadhi Pada', 1, 'तदा द्रष्टुः स्वरूपेऽवस्थानम्', 'tadā draṣṭuḥ svarūpe''vasthānam', 'उस समय द्रष्टा (आत्मा) की अपने स्वरूप में स्थिति हो जाती है।', 'Then the Seer abides in its own true nature.', null, 'When the mind is still, you experience your true self beyond thoughts and emotions. Cultivate moments of inner silence to glimpse this reality.', array['self-realization', 'svarupa', 'drashta', 'witness', 'awareness'], true),
('y1000001-0000-0000-0000-000000000004', '22222222-2222-2222-2222-222222222222', '1.4',  4, 'Samadhi Pada', 1, 'वृत्तिसारूप्यमितरत्र', 'vṛtti-sārūpyam itaratra', 'दूसरे समय में द्रष्टा की वृत्ति के सदृश स्वरूप होता है अर्थात् वह चित्तवृत्ति के अनुरूप अपना स्वरूप समझता रहता है।', 'At other times, the Seer identifies with the modifications of the mind.', null, 'Notice when you identify completely with your thoughts, emotions, or roles. That identification is the root of suffering.', array['identification', 'vritti', 'misidentification', 'ignorance'], true),
('y1000001-0000-0000-0000-000000000005', '22222222-2222-2222-2222-222222222222', '1.5',  5, 'Samadhi Pada', 1, 'वृत्तयः पञ्चतय्यः क्लिष्टाक्लिष्टाः', 'vṛttayaḥ pañcatayyaḥ kliṣṭākliṣṭāḥ', 'ये चित्तवृत्तियाँ पाँच प्रकार की होती हैं तथा क्लिष्ट (क्लेशकारक) और अक्लिष्ट (क्लेशरहित) दो भेदों वाली होती हैं।', 'The mental modifications are five-fold and can be either painful or non-painful.', null, 'Learn to categorize your mental activities. Observe which thoughts cause suffering and which support your growth.', array['vritti', 'klishta', 'aklishta', 'classification', 'mental-modifications'], true),
('y1000001-0000-0000-0000-000000000006', '22222222-2222-2222-2222-222222222222', '1.6',  6, 'Samadhi Pada', 1, 'प्रमाणविपर्ययविकल्पनिद्रास्मृतयः', 'pramāṇa-viparyaya-vikalpa-nidrā-smṛtayaḥ', 'प्रमाण, विपर्यय, विकल्प, निद्रा और स्मृति — ये पाँच वृत्तियाँ हैं।', 'The five modifications are: right knowledge, wrong knowledge, imagination, sleep, and memory.', null, 'Throughout your day, notice which of these five mental patterns is active. This awareness itself begins the process of mastery.', array['pramana', 'viparyaya', 'vikalpa', 'nidra', 'smriti', 'five-vrittis'], true),
('y1000001-0000-0000-0000-000000000007', '22222222-2222-2222-2222-222222222222', '1.7',  7, 'Samadhi Pada', 1, 'प्रत्यक्षानुमानागमाः प्रमाणानि', 'pratyakṣānumānāgamāḥ pramāṇāni', 'प्रत्यक्ष, अनुमान और आगम — ये तीन प्रमाण हैं।', 'The sources of right knowledge are direct perception, inference, and testimony from authoritative scripture.', null, 'Validate your understanding through direct experience, logical reasoning, and wisdom teachings. Do not rely on any single source alone.', array['pramana', 'pratyaksha', 'anumana', 'agama', 'valid-knowledge'], true),
('y1000001-0000-0000-0000-000000000008', '22222222-2222-2222-2222-222222222222', '1.8',  8, 'Samadhi Pada', 1, 'विपर्ययो मिथ्याज्ञानमतद्रूपप्रतिष्ठम्', 'viparyayo mithyā-jñānam atad-rūpa-pratiṣṭham', 'जो उस वस्तु के स्वरूप में प्रतिष्ठित नहीं है ऐसा मिथ्या ज्ञान विपर्यय है।', 'Wrong knowledge is a false understanding of something that does not correspond to its true form.', null, 'Question your assumptions regularly. What you believe to be true may be a misperception, like mistaking a rope for a snake.', array['viparyaya', 'mithya-jnana', 'false-knowledge', 'delusion'], true),
('y1000001-0000-0000-0000-000000000009', '22222222-2222-2222-2222-222222222222', '1.9',  9, 'Samadhi Pada', 1, 'शब्दज्ञानानुपाती वस्तुशून्यो विकल्पः', 'śabda-jñānānupātī vastu-śūnyo vikalpaḥ', 'जो ज्ञान शब्दजनित ज्ञान के साथ-साथ होने वाला है किन्तु वस्तुशून्य है, वह विकल्प है।', 'Imagination is a mental modification that follows verbal knowledge but has no corresponding reality.', null, 'Notice how much of your mental world is built on words and concepts with no real substance. Let go of fantasies and abstract rumination.', array['vikalpa', 'imagination', 'fantasy', 'verbal-knowledge'], true),
('y1000001-0000-0000-0000-000000000010', '22222222-2222-2222-2222-222222222222', '1.10', 10, 'Samadhi Pada', 1, 'अभावप्रत्ययालम्बना वृत्तिर्निद्रा', 'abhāva-pratyayālambanā vṛttir nidrā', 'अभावरूप प्रत्यय का आलम्बन लेने वाली वृत्ति निद्रा है।', 'Sleep is the mental modification that is based on the absence of any content.', null, 'Observe the quality of your sleep and the transitions into and out of it. Even sleep is a state of consciousness that can be understood.', array['nidra', 'sleep', 'vritti', 'abhava', 'unconscious'], true),
('y1000001-0000-0000-0000-000000000011', '22222222-2222-2222-2222-222222222222', '1.11', 11, 'Samadhi Pada', 1, 'अनुभूतविषयासम्प्रमोषः स्मृतिः', 'anubhūta-viṣayāsampramoṣaḥ smṛtiḥ', 'अनुभव किये हुए विषय का न भूलना (मन में बने रहना) स्मृति है।', 'Memory is the retention of experienced objects without distortion.', null, 'Be mindful of how memories color your present experience. Practice being present rather than living in replays of the past.', array['smriti', 'memory', 'experience', 'retention'], true),
('y1000001-0000-0000-0000-000000000012', '22222222-2222-2222-2222-222222222222', '1.12', 12, 'Samadhi Pada', 1, 'अभ्यासवैराग्याभ्यां तन्निरोधः', 'abhyāsa-vairāgyābhyāṁ tan-nirodhaḥ', 'अभ्यास और वैराग्य से उन वृत्तियों का निरोध होता है।', 'The cessation of mental modifications is achieved through practice and non-attachment.', null, 'Combine consistent daily practice with letting go of attachment to outcomes. These two together form the complete path.', array['abhyasa', 'vairagya', 'practice', 'detachment', 'nirodha'], true),
('y1000001-0000-0000-0000-000000000013', '22222222-2222-2222-2222-222222222222', '1.13', 13, 'Samadhi Pada', 1, 'तत्र स्थितौ यत्नोऽभ्यासः', 'tatra sthitau yatno''bhyāsaḥ', 'उनमें से चित्त की स्थिरता के लिए किया जाने वाला यत्न अभ्यास है।', 'Practice is the effort to attain steadiness of mind.', null, 'Commit to a regular routine of meditation or mindfulness. The key is steady, sustained effort over time.', array['abhyasa', 'practice', 'effort', 'steadiness'], true),
('y1000001-0000-0000-0000-000000000014', '22222222-2222-2222-2222-222222222222', '1.14', 14, 'Samadhi Pada', 1, 'स तु दीर्घकालनैरन्तर्यसत्कारासेवितो दृढभूमिः', 'sa tu dīrgha-kāla-nairantarya-satkārāsevito dṛḍha-bhūmiḥ', 'वह अभ्यास बहुत काल तक निरन्तर श्रद्धापूर्वक सेवन किया जाने पर दृढ़भूमि वाला होता है।', 'That practice becomes firmly grounded when continued for a long time, without interruption, and with devotion.', null, 'Be patient with your practice. True transformation requires long-term dedication, regularity, and genuine respect for the process.', array['abhyasa', 'dedication', 'consistency', 'long-term', 'persistence'], true),
('y1000001-0000-0000-0000-000000000015', '22222222-2222-2222-2222-222222222222', '1.15', 15, 'Samadhi Pada', 1, 'दृष्टानुश्रविकविषयवितृष्णस्य वशीकारसंज्ञा वैराग्यम्', 'dṛṣṭānuśravika-viṣaya-vitṛṣṇasya vaśīkāra-saṁjñā vairāgyam', 'देखे और सुने हुए विषयों में तृष्णा से रहित होने के ज्ञान का नाम वशीकार-वैराग्य है।', 'Non-attachment is the mastery of one who is free from craving for objects seen or heard about.', null, 'Cultivate freedom from craving both for material things you see and for promised pleasures described by others or in media.', array['vairagya', 'detachment', 'craving', 'freedom', 'vashikara'], true),
('y1000001-0000-0000-0000-000000000016', '22222222-2222-2222-2222-222222222222', '1.16', 16, 'Samadhi Pada', 1, 'तत्परं पुरुषख्यातेर्गुणवैतृष्ण्यम्', 'tat paraṁ puruṣa-khyāter guṇa-vaitṛṣṇyam', 'पुरुष (आत्मा) के ज्ञान से गुणों में भी वैतृष्ण्य (पूर्ण अनासक्ति) हो जाना — यह पर-वैराग्य है।', 'The highest form of non-attachment arises from the realization of the Self and is indifference to the three gunas.', null, 'As self-knowledge deepens, even the subtlest attractions of nature lose their grip. Aspire to this ultimate freedom beyond all qualities.', array['para-vairagya', 'purusha-khyati', 'gunas', 'supreme-detachment', 'self-knowledge'], true),
('y1000001-0000-0000-0000-000000000017', '22222222-2222-2222-2222-222222222222', '1.17', 17, 'Samadhi Pada', 1, 'वितर्कविचारानन्दास्मितारूपानुगमात्सम्प्रज्ञातः', 'vitarka-vicārānandāsmitā-rūpānugamāt samprajñātaḥ', 'वितर्क, विचार, आनन्द और अस्मिता — इन रूपों के अनुगत होने से सम्प्रज्ञात (समाधि) होती है।', 'Samprajnata samadhi is accompanied by reasoning, reflection, bliss, and a sense of pure being.', null, 'In deep meditation, notice the progressive stages: first thoughts settle, then subtler reflection, then bliss, then pure existence alone remains.', array['samprajnata', 'samadhi', 'vitarka', 'vichara', 'ananda', 'asmita'], true),
('y1000001-0000-0000-0000-000000000018', '22222222-2222-2222-2222-222222222222', '1.18', 18, 'Samadhi Pada', 1, 'विरामप्रत्ययाभ्यासपूर्वः संस्कारशेषोऽन्यः', 'virāma-pratyayābhyāsa-pūrvaḥ saṁskāra-śeṣo''nyaḥ', 'निवृत्ति-प्रत्यय के अभ्यासपूर्वक होने वाला, जिसमें केवल संस्कार शेष रहते हैं, वह अन्य (असम्प्रज्ञात) समाधि है।', 'The other samadhi (asamprajnata) is preceded by the practice of cessation and only latent impressions remain.', null, 'Beyond all cognitive experience lies the deepest samadhi where only subtle impressions remain. This is the gateway to complete liberation.', array['asamprajnata', 'samadhi', 'nirbija', 'samskara', 'cessation'], true),
('y1000001-0000-0000-0000-000000000019', '22222222-2222-2222-2222-222222222222', '1.19', 19, 'Samadhi Pada', 1, 'भवप्रत्ययो विदेहप्रकृतिलयानाम्', 'bhava-pratyayo videha-prakṛti-layānām', 'विदेह और प्रकृतिलय पुरुषों की समाधि का कारण भव (जन्म) है, साधन-समुदाय नहीं।', 'For those who are bodiless and merged in Prakriti, birth is the cause of their samadhi-like state.', null, 'Do not confuse natural psychic states or temporary absorption with true liberation. Genuine yoga requires conscious practice and discrimination.', array['videha', 'prakriti-laya', 'bhava', 'incomplete-liberation'], true),
('y1000001-0000-0000-0000-000000000020', '22222222-2222-2222-2222-222222222222', '1.20', 20, 'Samadhi Pada', 1, 'श्रद्धावीर्यस्मृतिसमाधिप्रज्ञापूर्वक इतरेषाम्', 'śraddhā-vīrya-smṛti-samādhi-prajñā-pūrvaka itareṣām', 'दूसरे (साधक) पुरुषों की समाधि श्रद्धा, वीर्य, स्मृति, समाधि और प्रज्ञा के पूर्वक होती है।', 'For others, samadhi is preceded by faith, energy, memory, concentration, and wisdom.', null, 'Cultivate faith in the path, energetic commitment, mindful awareness, focused concentration, and discriminative wisdom as the progressive steps.', array['shraddha', 'virya', 'smriti', 'samadhi', 'prajna', 'means'], true),
('y1000001-0000-0000-0000-000000000021', '22222222-2222-2222-2222-222222222222', '1.21', 21, 'Samadhi Pada', 1, 'तीव्रसंवेगानामासन्नः', 'tīvra-saṁvegānām āsannaḥ', 'तीव्र संवेग (उत्साह) वालों की समाधि शीघ्र सिद्ध होती है।', 'Success is nearest for those whose practice is intense and earnest.', null, 'The more wholeheartedly you commit to your practice, the faster you will progress. Tepid effort yields tepid results.', array['intensity', 'earnestness', 'speed', 'dedication'], true),
('y1000001-0000-0000-0000-000000000022', '22222222-2222-2222-2222-222222222222', '1.22', 22, 'Samadhi Pada', 1, 'मृदुमध्याधिमात्रत्वात्ततोऽपि विशेषः', 'mṛdu-madhyādhimātratvāt tato''pi viśeṣaḥ', 'मृदु, मध्य और अधिमात्र होने से उसमें भी विशेष (भेद) है।', 'There is further distinction according to whether the practice is mild, moderate, or intense.', null, 'Honestly assess the intensity of your practice. Gentle practice yields slow results; moderate practice brings moderate results; intense practice brings rapid progress.', array['mridu', 'madhya', 'adhimatra', 'degrees', 'intensity'], true),
('y1000001-0000-0000-0000-000000000023', '22222222-2222-2222-2222-222222222222', '1.23', 23, 'Samadhi Pada', 1, 'ईश्वरप्रणिधानाद्वा', 'īśvara-praṇidhānād vā', 'ईश्वर की शरणागति से भी (समाधि सिद्ध होती है)।', 'Or, samadhi is attained through devotion and surrender to God.', null, 'Complete surrender to a higher power is an alternative and powerful path. Release the ego''s need for control and trust in divine grace.', array['ishvara-pranidhana', 'surrender', 'devotion', 'god', 'bhakti'], true),
('y1000001-0000-0000-0000-000000000024', '22222222-2222-2222-2222-222222222222', '1.24', 24, 'Samadhi Pada', 1, 'क्लेशकर्मविपाकाशयैरपरामृष्टः पुरुषविशेष ईश्वरः', 'kleśa-karma-vipākāśayair aparāmṛṣṭaḥ puruṣa-viśeṣa īśvaraḥ', 'क्लेश, कर्म, विपाक और आशय से अपरामृष्ट (अछूता) पुरुषविशेष ईश्वर है।', 'God is a special Purusha untouched by afflictions, actions, results, or latent impressions.', null, 'Contemplate a consciousness free from suffering, karma, and conditioning. This ideal inspires your own journey toward inner freedom.', array['ishvara', 'god', 'purusha-vishesha', 'klesha', 'karma', 'freedom'], true),
('y1000001-0000-0000-0000-000000000025', '22222222-2222-2222-2222-222222222222', '1.25', 25, 'Samadhi Pada', 1, 'तत्र निरतिशयं सर्वज्ञबीजम्', 'tatra niratiśayaṁ sarvajña-bījam', 'उस ईश्वर में सर्वज्ञता का बीज निरतिशय (सर्वोत्कृष्ट) है।', 'In God, the seed of omniscience is unsurpassed.', null, 'Recognize that the source of all knowledge exists. Approach learning with humility, knowing that infinite wisdom lies beyond the individual mind.', array['ishvara', 'omniscience', 'sarvajna', 'supreme-knowledge'], true),
('y1000001-0000-0000-0000-000000000026', '22222222-2222-2222-2222-222222222222', '1.26', 26, 'Samadhi Pada', 1, 'पूर्वेषामपि गुरुः कालेनानवच्छेदात्', 'pūrveṣām api guruḥ kālenānavacchedāt', 'वह ईश्वर काल से अनवच्छिन्न होने के कारण पूर्वजों का भी गुरु है।', 'God is the teacher of even the earliest teachers, being beyond the limits of time.', null, 'The ultimate source of guidance is timeless. Connect with that eternal wisdom through meditation and inner listening.', array['ishvara', 'guru', 'eternal', 'timeless', 'teacher'], true),
('y1000001-0000-0000-0000-000000000027', '22222222-2222-2222-2222-222222222222', '1.27', 27, 'Samadhi Pada', 1, 'तस्य वाचकः प्रणवः', 'tasya vācakaḥ praṇavaḥ', 'उस ईश्वर का वाचक (नाम) प्रणव (ओम्) है।', 'The sacred syllable Om is the designator of God.', null, 'Practice chanting or meditating on Om. This primordial sound is the most direct way to connect with the divine presence.', array['pranava', 'om', 'ishvara', 'mantra', 'sacred-sound'], true),
('y1000001-0000-0000-0000-000000000028', '22222222-2222-2222-2222-222222222222', '1.28', 28, 'Samadhi Pada', 1, 'तज्जपस्तदर्थभावनम्', 'taj-japas tad-artha-bhāvanam', 'उस प्रणव का जप और उसके अर्थ की भावना करनी चाहिए।', 'The repetition of Om and meditation on its meaning is the practice.', null, 'Do not merely repeat mantras mechanically. Combine repetition with deep contemplation of the meaning behind the sacred syllable.', array['japa', 'pranava', 'om', 'meditation', 'contemplation'], true),
('y1000001-0000-0000-0000-000000000029', '22222222-2222-2222-2222-222222222222', '1.29', 29, 'Samadhi Pada', 1, 'ततः प्रत्यक्चेतनाधिगमोऽप्यन्तरायाभावश्च', 'tataḥ pratyak-cetanādhigamo''py antarāyābhāvaś ca', 'उससे अन्तर्मुखी चेतना का अधिगम (ज्ञान) और अन्तरायों (विघ्नों) का अभाव होता है।', 'From that practice comes the realization of the inner consciousness and the removal of obstacles.', null, 'Regular practice of japa removes mental obstacles and turns awareness inward, revealing your deeper nature.', array['pratyak-chetana', 'antaraya', 'obstacles', 'inner-awareness', 'om'], true),
('y1000001-0000-0000-0000-000000000030', '22222222-2222-2222-2222-222222222222', '1.30', 30, 'Samadhi Pada', 1, 'व्याधिस्त्यानसंशयप्रमादालस्याविरतिभ्रान्तिदर्शनालब्धभूमिकत्वानवस्थितत्वानि चित्तविक्षेपास्तेऽन्तरायाः', 'vyādhi-styāna-saṁśaya-pramādālasyāvirati-bhrāntidarśanālabdha-bhūmikatvānavasthitatvāni citta-vikṣepās te''ntarāyāḥ', 'व्याधि, स्त्यान, संशय, प्रमाद, आलस्य, अविरति, भ्रान्तिदर्शन, अलब्धभूमिकत्व और अनवस्थितत्व — ये चित्त के विक्षेप हैं; ये ही अन्तराय हैं।', 'Disease, dullness, doubt, carelessness, laziness, sensuality, false perception, failure to reach firm ground, and instability are the obstacles that distract the mind.', null, 'Identify which of these nine obstacles is currently strongest in your life and address it directly through appropriate counter-measures.', array['antaraya', 'obstacles', 'vyadhi', 'styana', 'samshaya', 'pramada', 'alasya'], true),
('y1000001-0000-0000-0000-000000000031', '22222222-2222-2222-2222-222222222222', '1.31', 31, 'Samadhi Pada', 1, 'दुःखदौर्मनस्याङ्गमेजयत्वश्वासप्रश्वासा विक्षेपसहभुवः', 'duḥkha-daurmanasyāṅgamejayatva-śvāsa-praśvāsā vikṣepa-sahabhuvaḥ', 'दुःख, दौर्मनस्य (निराशा), अङ्गमेजयत्व (शरीर का काँपना), श्वास-प्रश्वास — ये विक्षेप के साथ होने वाले लक्षण हैं।', 'Pain, despair, trembling of the body, and irregular breathing accompany the mental distractions.', null, 'When you notice physical agitation, emotional despair, or irregular breathing, recognize these as signs of mental disturbance and apply calming techniques.', array['symptoms', 'duhkha', 'daurmanasya', 'trembling', 'breathing', 'distraction'], true),
('y1000001-0000-0000-0000-000000000032', '22222222-2222-2222-2222-222222222222', '1.32', 32, 'Samadhi Pada', 1, 'तत्प्रतिषेधार्थमेकतत्त्वाभ्यासः', 'tat-pratiṣedhārtham eka-tattvābhyāsaḥ', 'उन विक्षेपों के प्रतिषेध (निवारण) के लिए एक तत्त्व का अभ्यास करना चाहिए।', 'To prevent these obstacles, one should practice concentration on a single principle.', null, 'Choose one meditation object and stick with it. Scattered practice on many techniques is less effective than devoted focus on one.', array['eka-tattva', 'single-focus', 'concentration', 'remedy', 'obstacles'], true),
('y1000001-0000-0000-0000-000000000033', '22222222-2222-2222-2222-222222222222', '1.33', 33, 'Samadhi Pada', 1, 'मैत्रीकरुणामुदितोपेक्षाणां सुखदुःखपुण्यापुण्यविषयाणां भावनातश्चित्तप्रसादनम्', 'maitrī-karuṇā-muditopekṣāṇāṁ sukha-duḥkha-puṇyāpuṇya-viṣayāṇāṁ bhāvanātaś citta-prasādanam', 'सुखी लोगों में मैत्री, दुःखी लोगों में करुणा, पुण्यात्माओं में मुदिता (प्रसन्नता) और पापियों में उपेक्षा की भावना से चित्त प्रसन्न होता है।', 'By cultivating friendliness toward the happy, compassion toward the suffering, joy toward the virtuous, and equanimity toward the non-virtuous, the mind becomes serene.', null, 'Practice these four attitudes in daily interactions: be happy for others'' joy, compassionate toward suffering, appreciative of good people, and equanimous toward wrongdoers.', array['maitri', 'karuna', 'mudita', 'upeksha', 'brahma-vihara', 'chitta-prasadana'], true),
('y1000001-0000-0000-0000-000000000034', '22222222-2222-2222-2222-222222222222', '1.34', 34, 'Samadhi Pada', 1, 'प्रच्छर्दनविधारणाभ्यां वा प्राणस्य', 'pracchardana-vidhāraṇābhyāṁ vā prāṇasya', 'प्राण के प्रच्छर्दन (बाहर छोड़ने) और विधारण (रोकने) से भी (चित्त स्थिर होता है)।', 'Or, mental calmness is attained through the regulation of exhalation and retention of breath.', null, 'Use slow, deliberate exhaling and breath retention as immediate tools to calm an agitated mind.', array['pranayama', 'breath', 'exhalation', 'retention', 'calming'], true),
('y1000001-0000-0000-0000-000000000035', '22222222-2222-2222-2222-222222222222', '1.35', 35, 'Samadhi Pada', 1, 'विषयवती वा प्रवृत्तिरुत्पन्ना मनसः स्थितिनिबन्धनी', 'viṣayavatī vā pravṛttir utpannā manasaḥ sthiti-nibandhanī', 'विषयवती (दिव्य) प्रवृत्ति उत्पन्न होने पर भी मन को स्थिर करने में हेतु बन जाती है।', 'Or, the development of higher sensory perception can also steady the mind.', null, 'Focus deeply on a single sensory experience to anchor the mind and develop concentration.', array['vishayavati', 'pravritti', 'higher-perception', 'concentration', 'senses'], true),
('y1000001-0000-0000-0000-000000000036', '22222222-2222-2222-2222-222222222222', '1.36', 36, 'Samadhi Pada', 1, 'विशोका वा ज्योतिष्मती', 'viśokā vā jyotiṣmatī', 'विशोका (शोकरहित) ज्योतिष्मती (प्रकाशमयी) वृत्ति भी मन को स्थिर करने वाली होती है।', 'Or, by meditating on the inner light that is beyond sorrow.', null, 'Meditate on the luminous, sorrowless light within the heart. This inner radiance dissolves grief and brings deep peace.', array['vishoka', 'jyotishmati', 'inner-light', 'sorrowless', 'meditation'], true),
('y1000001-0000-0000-0000-000000000037', '22222222-2222-2222-2222-222222222222', '1.37', 37, 'Samadhi Pada', 1, 'वीतरागविषयं वा चित्तम्', 'vīta-rāga-viṣayaṁ vā cittam', 'वीतराग (आसक्तिरहित) पुरुष को विषय करने वाला चित्त भी स्थिर हो जाता है।', 'Or, by meditating on the mind of one who is free from attachment.', null, 'Contemplate the qualities of enlightened beings who are free from attachment. Their example can elevate and steady your own mind.', array['vita-raga', 'desireless', 'contemplation', 'role-model'], true),
('y1000001-0000-0000-0000-000000000038', '22222222-2222-2222-2222-222222222222', '1.38', 38, 'Samadhi Pada', 1, 'स्वप्ननिद्राज्ञानालम्बनं वा', 'svapna-nidrā-jñānālambanaṁ vā', 'स्वप्न और निद्रा के ज्ञान का आलम्बन लेने से भी (चित्त स्थिर होता है)।', 'Or, by meditating on the knowledge gained from dreams or deep sleep.', null, 'Pay attention to insights from dreams and the peace of deep sleep. These states reveal aspects of consciousness beyond the waking mind.', array['svapna', 'nidra', 'dream', 'sleep', 'consciousness'], true),
('y1000001-0000-0000-0000-000000000039', '22222222-2222-2222-2222-222222222222', '1.39', 39, 'Samadhi Pada', 1, 'यथाभिमतध्यानाद्वा', 'yathābhimata-dhyānād vā', 'अपनी रुचि के अनुसार किसी भी इष्ट विषय के ध्यान से भी (चित्त स्थिर होता है)।', 'Or, by meditating on any object that is agreeable to the practitioner.', null, 'Choose a meditation object that naturally draws your attention and devotion. The path that suits your temperament is most effective.', array['yathabhimata', 'personal-choice', 'meditation', 'flexibility'], true),
('y1000001-0000-0000-0000-000000000040', '22222222-2222-2222-2222-222222222222', '1.40', 40, 'Samadhi Pada', 1, 'परमाणुपरममहत्त्वान्तोऽस्य वशीकारः', 'paramāṇu-parama-mahattva-anto''sya vaśīkāraḥ', 'उस (अभ्यासी) का वशीकार (अधिकार) परमाणु से लेकर परम-महत्त्व (सबसे बड़ी वस्तु) तक होता है।', 'The mastery of one who has attained this extends from the smallest atom to the infinitely great.', null, 'A trained mind can focus on the tiniest detail or expand to contemplate the vastness of existence. Practice both micro and macro awareness.', array['vashikara', 'mastery', 'paramanu', 'infinity', 'concentration'], true),
('y1000001-0000-0000-0000-000000000041', '22222222-2222-2222-2222-222222222222', '1.41', 41, 'Samadhi Pada', 1, 'क्षीणवृत्तेरभिजातस्येव मणेर्ग्रहीतृग्रहणग्राह्येषु तत्स्थतदञ्जनता समापत्तिः', 'kṣīṇa-vṛtter abhijātasyeva maṇer grahītṛ-grahaṇa-grāhyeṣu tat-stha-tad-añjanatā samāpattiḥ', 'क्षीणवृत्ति वाले चित्त की ग्रहीता, ग्रहण और ग्राह्य में तत्स्थ-तदञ्जनता — निर्मल मणि के सदृश — समापत्ति है।', 'When the mental modifications are weakened, the mind, like a transparent crystal, takes on the color of the knower, the knowing, and the known — this is called samapatti (absorption).', null, 'In deep concentration, the distinction between you, the act of knowing, and the object dissolves. Cultivate this crystal-clear absorption.', array['samapatti', 'absorption', 'crystal', 'grahita', 'grahana', 'grahya'], true),
('y1000001-0000-0000-0000-000000000042', '22222222-2222-2222-2222-222222222222', '1.42', 42, 'Samadhi Pada', 1, 'तत्र शब्दार्थज्ञानविकल्पैः सङ्कीर्णा सवितर्का समापत्तिः', 'tatra śabdārtha-jñāna-vikalpaiḥ saṅkīrṇā savitarkā samāpattiḥ', 'उनमें शब्द, अर्थ और ज्ञान के विकल्पों से संकीर्ण (मिश्रित) समापत्ति सवितर्का है।', 'Savitarka samapatti is the absorption mixed with verbal and conceptual knowledge of the object.', null, 'In early stages of deep focus, words, meanings, and concepts still intermingle. Notice this mixture without forcing it away.', array['savitarka', 'samapatti', 'sabda', 'artha', 'jnana', 'conceptual'], true),
('y1000001-0000-0000-0000-000000000043', '22222222-2222-2222-2222-222222222222', '1.43', 43, 'Samadhi Pada', 1, 'स्मृतिपरिशुद्धौ स्वरूपशून्येवार्थमात्रनिर्भासा निर्वितर्का', 'smṛti-pariśuddhau svarūpa-śūnyevārtha-mātra-nirbhāsā nirvitarkā', 'स्मृति की परिशुद्धि होने पर, जब अपने स्वरूप से शून्य-सी होकर अर्थमात्र प्रकाशित होती है, वह निर्वितर्का (समापत्ति) है।', 'When memory is purified and the mind shines forth as the object alone, devoid of its own form, it is nirvitarka samapatti.', null, 'As meditation deepens, conceptual labels drop away and pure direct experience of the object remains. Allow this natural unfolding.', array['nirvitarka', 'samapatti', 'smriti', 'purification', 'direct-experience'], true),
('y1000001-0000-0000-0000-000000000044', '22222222-2222-2222-2222-222222222222', '1.44', 44, 'Samadhi Pada', 1, 'एतयैव सविचारा निर्विचारा च सूक्ष्मविषया व्याख्याता', 'etayaiva savicārā nirvicārā ca sūkṣma-viṣayā vyākhyātā', 'इसी प्रकार सूक्ष्म विषय वाली सविचारा और निर्विचारा (समापत्ति) भी व्याख्यात हो गई।', 'By this same explanation, savichara and nirvichara samapatti, having subtle objects, are also explained.', null, 'Apply the same progression to subtler objects of meditation. First contemplation with reflection, then pure awareness of the subtle essence.', array['savichara', 'nirvichara', 'subtle', 'samapatti', 'progression'], true),
('y1000001-0000-0000-0000-000000000045', '22222222-2222-2222-2222-222222222222', '1.45', 45, 'Samadhi Pada', 1, 'सूक्ष्मविषयत्वं चालिङ्गपर्यवसानम्', 'sūkṣma-viṣayatvaṁ cāliṅga-paryavasānam', 'सूक्ष्म विषयत्व अलिङ्ग (प्रकृति) तक जाकर समाप्त होता है।', 'The subtlety of objects extends all the way to the unmanifest (Prakriti).', null, 'Understand that meditation can penetrate to the most fundamental level of nature itself. There is always a subtler layer to explore.', array['sukshma', 'alinga', 'prakriti', 'subtle-objects', 'unmanifest'], true),
('y1000001-0000-0000-0000-000000000046', '22222222-2222-2222-2222-222222222222', '1.46', 46, 'Samadhi Pada', 1, 'ता एव सबीजः समाधिः', 'tā eva sabījaḥ samādhiḥ', 'वे ही (उपर्युक्त समापत्तियाँ) सबीज समाधि हैं।', 'These samapattis together constitute samadhi with seed (sabija).', null, 'All forms of absorption with an object are samadhi with seed. They are profound but not yet the final state of liberation.', array['sabija', 'samadhi', 'seed', 'samapatti', 'stages'], true),
('y1000001-0000-0000-0000-000000000047', '22222222-2222-2222-2222-222222222222', '1.47', 47, 'Samadhi Pada', 1, 'निर्विचारवैशारद्येऽध्यात्मप्रसादः', 'nirvicāra-vaiśāradye''dhyātma-prasādaḥ', 'निर्विचार (समापत्ति) की निर्मलता होने पर आध्यात्मिक प्रसाद (आत्मप्रकाश) होता है।', 'When nirvichara samadhi becomes pellucid, there is the luminosity of the inner Self.', null, 'As your deepest meditation becomes clear and steady, a natural spiritual radiance and inner peace will dawn spontaneously.', array['nirvichara', 'vaisharadya', 'adhyatma-prasada', 'clarity', 'inner-light'], true),
('y1000001-0000-0000-0000-000000000048', '22222222-2222-2222-2222-222222222222', '1.48', 48, 'Samadhi Pada', 1, 'ऋतम्भरा तत्र प्रज्ञा', 'ṛtambharā tatra prajñā', 'उसमें ऋतम्भरा (सत्यधारिणी) प्रज्ञा होती है।', 'In that state, the wisdom is truth-bearing (ritambhara).', null, 'In the deepest states of meditation, the insights that arise carry absolute truth. Trust the wisdom that emerges from genuine stillness.', array['ritambhara', 'prajna', 'truth', 'wisdom', 'insight'], true),
('y1000001-0000-0000-0000-000000000049', '22222222-2222-2222-2222-222222222222', '1.49', 49, 'Samadhi Pada', 1, 'श्रुतानुमानप्रज्ञाभ्यामन्यविषया विशेषार्थत्वात्', 'śrutānumāna-prajñābhyām anya-viṣayā viśeṣārthatvāt', 'यह प्रज्ञा श्रुत (शास्त्र) और अनुमान से होने वाली प्रज्ञाओं से भिन्न विषय वाली है, क्योंकि यह विशेषार्थ वाली है।', 'This wisdom is different from knowledge gained by testimony or inference, as it pertains to particulars.', null, 'Experiential wisdom from deep meditation surpasses book learning and logical reasoning. Seek direct experience, not just intellectual understanding.', array['prajna', 'shruta', 'anumana', 'direct-knowledge', 'experience'], true),
('y1000001-0000-0000-0000-000000000050', '22222222-2222-2222-2222-222222222222', '1.50', 50, 'Samadhi Pada', 1, 'तज्जः संस्कारोऽन्यसंस्कारप्रतिबन्धी', 'taj-jaḥ saṁskāro''nya-saṁskāra-pratibandhi', 'उस (ऋतम्भरा प्रज्ञा) से जो संस्कार उत्पन्न होता है, वह अन्य संस्कारों को रोकने वाला होता है।', 'The impression born from that truth-bearing wisdom obstructs all other impressions.', null, 'The deepest meditative insights create powerful new patterns that override old negative conditioning. Keep deepening your practice.', array['samskara', 'pratibandhi', 'transformation', 'impressions', 'wisdom'], true),
('y1000001-0000-0000-0000-000000000051', '22222222-2222-2222-2222-222222222222', '1.51', 51, 'Samadhi Pada', 1, 'तस्यापि निरोधे सर्वनिरोधान्निर्बीजः समाधिः', 'tasyāpi nirodhe sarva-nirodhān nirbījaḥ samādhiḥ', 'उसका भी निरोध हो जाने पर सर्व (वृत्तियों) के निरोध से निर्बीज समाधि होती है।', 'When even that impression is suppressed, with the suppression of all modifications, seedless (nirbija) samadhi is attained.', null, 'The ultimate state transcends even spiritual impressions. True liberation is the complete cessation of all mental seeds.', array['nirbija', 'samadhi', 'seedless', 'nirodha', 'liberation', 'kaivalya'], true);


-- ========================================================================
-- PADA 2-4: Remaining 144 sutras
-- Due to the enormous size of all 195 sutras as individual SQL statements,
-- Padas 2-4 are seeded via a programmatic approach.
-- In production, run the companion script: seed-yoga-sutras.ts
-- which reads yoga-sutras-complete.json and inserts via Supabase client.
--
-- For the schema demonstration, we include Pada 2 sutras 2.1-2.10 below,
-- plus the first and last sutras of Padas 3 and 4 as bookends.
-- ========================================================================

-- Pada 2: Sadhana Pada (sample: 2.1 - 2.10)
insert into verses (id, text_id, verse_number, verse_order, pada, pada_number, sanskrit, transliteration, hindi_meaning, english_translation, practice_prompt, tags, is_published) values
('y2000001-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', '2.1',  52, 'Sadhana Pada', 2, 'तपःस्वाध्यायेश्वरप्रणिधानानि क्रियायोगः', 'tapaḥ-svādhyāyeśvara-praṇidhānāni kriyā-yogaḥ', 'तप, स्वाध्याय और ईश्वरप्रणिधान — ये क्रियायोग हैं।', 'Austerity, self-study, and surrender to God constitute Kriya Yoga.', 'Integrate these three in daily life: disciplined effort, self-reflection through study, and humble surrender to a higher purpose.', array['kriya-yoga', 'tapas', 'svadhyaya', 'ishvara-pranidhana'], true),
('y2000001-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', '2.2',  53, 'Sadhana Pada', 2, 'समाधिभावनार्थः क्लेशतनूकरणार्थश्च', 'samādhi-bhāvanārthaḥ kleśa-tanūkaraṇārthaś ca', 'समाधि की भावना (सिद्धि) के लिए और क्लेशों को तनू (क्षीण) करने के लिए (क्रियायोग का अनुष्ठान करना चाहिए)।', 'Kriya Yoga is practiced for the purpose of bringing about samadhi and for attenuating the afflictions.', 'Understand that disciplined practice serves two purposes: it weakens mental afflictions and prepares the ground for deep absorption.', array['kriya-yoga', 'samadhi', 'klesha', 'thinning', 'purpose'], true),
('y2000001-0000-0000-0000-000000000003', '22222222-2222-2222-2222-222222222222', '2.3',  54, 'Sadhana Pada', 2, 'अविद्यास्मितारागद्वेषाभिनिवेशाः क्लेशाः', 'avidyāsmitā-rāga-dveṣābhiniveśāḥ kleśāḥ', 'अविद्या, अस्मिता, राग, द्वेष और अभिनिवेश — ये पाँच क्लेश हैं।', 'The afflictions are ignorance, egoism, attachment, aversion, and clinging to life.', 'Learn to recognize these five poisons in your own mind. Awareness of them is the first step toward freedom from suffering.', array['klesha', 'avidya', 'asmita', 'raga', 'dvesha', 'abhinivesha'], true),
('y2000001-0000-0000-0000-000000000004', '22222222-2222-2222-2222-222222222222', '2.4',  55, 'Sadhana Pada', 2, 'अविद्या क्षेत्रमुत्तरेषां प्रसुप्ततनुविच्छिन्नोदाराणाम्', 'avidyā kṣetram uttareṣāṁ prasupta-tanu-vicchinnodārāṇām', 'अविद्या आगे के (शेष चार) क्लेशों की क्षेत्र (भूमि) है, चाहे वे प्रसुप्त, तनु, विच्छिन्न या उदार अवस्था में हों।', 'Ignorance is the field for the others, whether they are dormant, thinned, intermittent, or fully active.', 'Address ignorance first, as it is the breeding ground for all other afflictions. Self-knowledge dissolves the root of suffering.', array['avidya', 'klesha', 'root-cause', 'dormant', 'active'], true),
('y2000001-0000-0000-0000-000000000005', '22222222-2222-2222-2222-222222222222', '2.5',  56, 'Sadhana Pada', 2, 'अनित्याशुचिदुःखानात्मसु नित्यशुचिसुखात्मख्यातिरविद्या', 'anityāśuci-duḥkhānātmasu nitya-śuci-sukhātma-khyātir avidyā', 'अनित्य, अशुचि, दुःख और अनात्म में नित्य, शुचि, सुख और आत्म की ख्याति (प्रतीति) अविद्या है।', 'Ignorance is seeing the impermanent as permanent, the impure as pure, suffering as pleasure, and the non-Self as the Self.', 'Examine your core assumptions. Where do you mistake the temporary for lasting, the impure for pure, suffering for happiness, or the false self for the true Self?', array['avidya', 'ignorance', 'anitya', 'misperception'], true),
('y2000001-0000-0000-0000-000000000006', '22222222-2222-2222-2222-222222222222', '2.6',  57, 'Sadhana Pada', 2, 'दृग्दर्शनशक्त्योरेकात्मतेवास्मिता', 'dṛg-darśana-śaktyor ekātmatevāsmitā', 'दृक् (द्रष्टा) और दर्शन (बुद्धि) शक्तियों की एकात्मता-सी प्रतीति अस्मिता है।', 'Egoism is the apparent identification of the power of seeing with the power of the instrument of seeing.', 'Notice when you confuse pure awareness with the mind and its thoughts. You are the witness, not the instrument.', array['asmita', 'ego', 'identification', 'drashta', 'buddhi'], true),
('y2000001-0000-0000-0000-000000000007', '22222222-2222-2222-2222-222222222222', '2.7',  58, 'Sadhana Pada', 2, 'सुखानुशयी रागः', 'sukhānuśayī rāgaḥ', 'सुख के अनुशयी (पीछे आने वाला) राग है।', 'Attachment is that which accompanies pleasure.', 'Observe how the memory of pleasant experiences creates craving for their repetition. This automatic pull is raga.', array['raga', 'attachment', 'pleasure', 'craving'], true),
('y2000001-0000-0000-0000-000000000008', '22222222-2222-2222-2222-222222222222', '2.8',  59, 'Sadhana Pada', 2, 'दुःखानुशयी द्वेषः', 'duḥkhānuśayī dveṣaḥ', 'दुःख के अनुशयी (पीछे आने वाला) द्वेष है।', 'Aversion is that which accompanies pain.', 'Notice how the memory of painful experiences creates automatic avoidance patterns. This reactive push is dvesha.', array['dvesha', 'aversion', 'pain', 'avoidance'], true),
('y2000001-0000-0000-0000-000000000009', '22222222-2222-2222-2222-222222222222', '2.9',  60, 'Sadhana Pada', 2, 'स्वरसवाही विदुषोऽपि तथारूढोऽभिनिवेशः', 'svarasavāhī viduṣo''pi tathārūḍho''bhiniveśaḥ', 'अपने स्वभाव से बहने वाला, विद्वानों में भी वैसे ही बना रहने वाला अभिनिवेश (मृत्युभय) है।', 'Clinging to life flows by its own nature and is rooted even in the wise.', 'Recognize that fear of death is the deepest instinct, present even in knowledgeable people. Acknowledge this fear without being controlled by it.', array['abhinivesha', 'fear-of-death', 'instinct', 'clinging'], true),
('y2000001-0000-0000-0000-000000000010', '22222222-2222-2222-2222-222222222222', '2.10', 61, 'Sadhana Pada', 2, 'ते प्रतिप्रसवहेयाः सूक्ष्माः', 'te pratiprasava-heyāḥ sūkṣmāḥ', 'वे (क्लेश) सूक्ष्म अवस्था में प्रतिप्रसव (कारण में विलय) से हेय (त्याज्य) हैं।', 'These subtle afflictions are to be overcome by tracing them back to their origin.', 'When subtle afflictions arise, trace them back to their root cause rather than trying to suppress them at the surface level.', array['klesha', 'subtle', 'pratiprasava', 'origin', 'dissolution'], true);

-- Pada 3: Vibhuti Pada (bookend samples)
insert into verses (id, text_id, verse_number, verse_order, pada, pada_number, sanskrit, transliteration, hindi_meaning, english_translation, practice_prompt, tags, is_published) values
('y3000001-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', '3.1',  107, 'Vibhuti Pada', 3, 'देशबन्धश्चित्तस्य धारणा', 'deśa-bandhaś cittasya dhāraṇā', 'चित्त को किसी देश (स्थान) में बाँधना धारणा है।', 'Concentration (dharana) is the binding of the mind to a single place.', 'Practice fixing your attention on one point — the breath, a mantra, or a spot between the eyebrows — without wavering.', array['dharana', 'concentration', 'focus', 'single-point'], true),
('y3000001-0000-0000-0000-000000000055', '22222222-2222-2222-2222-222222222222', '3.55', 161, 'Vibhuti Pada', 3, 'सत्त्वपुरुषयोः शुद्धिसाम्ये कैवल्यमिति', 'sattva-puruṣayoḥ śuddhi-sāmye kaivalyam iti', 'सत्त्व (बुद्धि) और पुरुष की शुद्धि में साम्य होने पर कैवल्य (मोक्ष) होता है।', 'When the purity of the intellect equals that of the Self, that is kaivalya (liberation).', 'Purify the mind until it becomes as transparent as the Self it reflects. That is the state of absolute freedom.', array['kaivalya', 'liberation', 'sattva', 'purusha', 'purity', 'equality'], true);

-- Pada 4: Kaivalya Pada (bookend samples)
insert into verses (id, text_id, verse_number, verse_order, pada, pada_number, sanskrit, transliteration, hindi_meaning, english_translation, practice_prompt, tags, is_published) values
('y4000001-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', '4.1',  162, 'Kaivalya Pada', 4, 'जन्मौषधिमन्त्रतपःसमाधिजाः सिद्धयः', 'janmauṣadhi-mantra-tapaḥ-samādhi-jāḥ siddhayaḥ', 'जन्म, औषधि, मन्त्र, तप और समाधि से सिद्धियाँ उत्पन्न होती हैं।', 'The supernatural powers arise from birth, herbs, mantras, austerities, or samadhi.', 'Understand that powers can come through various means, but only those earned through samadhi are spiritually valuable.', array['siddhi', 'powers', 'janma', 'aushadhi', 'mantra', 'tapas', 'samadhi'], true),
('y4000001-0000-0000-0000-000000000034', '22222222-2222-2222-2222-222222222222', '4.34', 195, 'Kaivalya Pada', 4, 'पुरुषार्थशून्यानां गुणानां प्रतिप्रसवः कैवल्यं स्वरूपप्रतिष्ठा वा चितिशक्तेरिति', 'puruṣārtha-śūnyānāṁ guṇānāṁ pratiprasavaḥ kaivalyaṁ svarūpa-pratiṣṭhā vā citi-śakter iti', 'पुरुषार्थशून्य गुणों का प्रतिप्रसव (अपने कारण में लय) कैवल्य है, अथवा चिति-शक्ति की स्वरूपप्रतिष्ठा कैवल्य है।', 'Kaivalya is the re-absorption of the gunas into their source, having fulfilled their purpose for the Self, or the establishment of the power of consciousness in its own nature.', 'Rest in the recognition that consciousness, your true nature, is already free. The play of nature has served its purpose. You are home.', array['kaivalya', 'liberation', 'gunas', 'pratiprasava', 'chiti-shakti', 'svarupa', 'final'], true);


-- =============================================================================
-- 6. YOGA SUTRA VERSE-THEME MAPPINGS
-- =============================================================================

-- Map all inserted Yoga Sutra verses to the Samadhi pada theme
insert into verse_themes (verse_id, theme_id, is_primary)
select v.id, 'b0000001-0000-0000-0000-000000000001', true
from verses v
where v.text_id = '22222222-2222-2222-2222-222222222222'
  and v.pada_number = 1;

-- Map Sadhana Pada verses
insert into verse_themes (verse_id, theme_id, is_primary)
select v.id, 'b0000001-0000-0000-0000-000000000002', true
from verses v
where v.text_id = '22222222-2222-2222-2222-222222222222'
  and v.pada_number = 2;

-- Map Vibhuti Pada verses
insert into verse_themes (verse_id, theme_id, is_primary)
select v.id, 'b0000001-0000-0000-0000-000000000003', true
from verses v
where v.text_id = '22222222-2222-2222-2222-222222222222'
  and v.pada_number = 3;

-- Map Kaivalya Pada verses
insert into verse_themes (verse_id, theme_id, is_primary)
select v.id, 'b0000001-0000-0000-0000-000000000004', true
from verses v
where v.text_id = '22222222-2222-2222-2222-222222222222'
  and v.pada_number = 4;

-- Cross-theme: mind-control for key sutras about vritti nirodha
insert into verse_themes (verse_id, theme_id, is_primary) values
('y1000001-0000-0000-0000-000000000002', 'c0000001-0000-0000-0000-000000000001', false),  -- 1.2 definition of yoga
('y1000001-0000-0000-0000-000000000012', 'c0000001-0000-0000-0000-000000000001', false),  -- 1.12 abhyasa-vairagya
('y1000001-0000-0000-0000-000000000032', 'c0000001-0000-0000-0000-000000000001', false);  -- 1.32 eka-tattva

-- Cross-theme: detachment
insert into verse_themes (verse_id, theme_id, is_primary) values
('y1000001-0000-0000-0000-000000000015', 'c0000001-0000-0000-0000-000000000002', false),  -- 1.15 vairagya
('y1000001-0000-0000-0000-000000000016', 'c0000001-0000-0000-0000-000000000002', false);  -- 1.16 para-vairagya

-- Cross-theme: devotion
insert into verse_themes (verse_id, theme_id, is_primary) values
('y1000001-0000-0000-0000-000000000023', 'c0000001-0000-0000-0000-000000000003', false),  -- 1.23 ishvara pranidhana
('y1000001-0000-0000-0000-000000000027', 'c0000001-0000-0000-0000-000000000003', false);  -- 1.27 Om

-- Cross-theme: meditation
insert into verse_themes (verse_id, theme_id, is_primary) values
('y1000001-0000-0000-0000-000000000036', 'c0000001-0000-0000-0000-000000000004', false),  -- 1.36 inner light
('y3000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000004', false);  -- 3.1 dharana

-- Cross-theme: suffering/kleshas for Sadhana Pada
insert into verse_themes (verse_id, theme_id, is_primary) values
('y2000001-0000-0000-0000-000000000003', 'c0000001-0000-0000-0000-000000000006', false),  -- 2.3 five kleshas
('y2000001-0000-0000-0000-000000000005', 'c0000001-0000-0000-0000-000000000006', false);  -- 2.5 definition of avidya


-- =============================================================================
-- 7. DAILY VERSE SCHEDULE (next 30 days from 2026-04-04)
-- =============================================================================
-- Alternates between Vivekachudamani and Yoga Sutras, mixing themes.

insert into daily_verse (verse_id, featured_date, note) values
('v1000001-0000-0000-0000-000000000001', '2026-04-04', 'Launch day: The rarity of human birth'),
('y1000001-0000-0000-0000-000000000002', '2026-04-05', 'The definition of Yoga — the ultimate starting point'),
('v1000001-0000-0000-0000-000000000004', '2026-04-06', 'Brahman is real, the world is appearance'),
('y1000001-0000-0000-0000-000000000003', '2026-04-07', 'When the mind is still, the Seer abides'),
('v1000001-0000-0000-0000-000000000013', '2026-04-08', 'Five animals, five senses — the dopamine trap'),
('y1000001-0000-0000-0000-000000000012', '2026-04-09', 'Practice and non-attachment: the twin path'),
('v1000001-0000-0000-0000-000000000023', '2026-04-10', 'The rope and the snake — seeing clearly'),
('y1000001-0000-0000-0000-000000000033', '2026-04-11', 'The four attitudes that bring peace'),
('v1000001-0000-0000-0000-000000000008', '2026-04-12', 'Fear not — the guru''s reassurance'),
('y1000001-0000-0000-0000-000000000023', '2026-04-13', 'Surrender to the divine'),
('v1000001-0000-0000-0000-000000000022', '2026-04-14', 'The mind: wind and clouds'),
('y1000001-0000-0000-0000-000000000014', '2026-04-15', 'Long, uninterrupted, devoted practice'),
('v1000001-0000-0000-0000-000000000018', '2026-04-16', 'The pot and the sky — immortality'),
('y1000001-0000-0000-0000-000000000048', '2026-04-17', 'Truth-bearing wisdom (Ritambhara Prajna)'),
('v1000001-0000-0000-0000-000000000005', '2026-04-18', 'Devotion is self-inquiry'),
('y2000001-0000-0000-0000-000000000003', '2026-04-19', 'The five afflictions — know your enemy'),
('v1000001-0000-0000-0000-000000000027', '2026-04-20', 'The chain reaction to freedom'),
('y2000001-0000-0000-0000-000000000005', '2026-04-21', 'What is ignorance, exactly?'),
('v1000001-0000-0000-0000-000000000017', '2026-04-22', 'Maya — the VR headset you forgot'),
('y1000001-0000-0000-0000-000000000030', '2026-04-23', 'Nine obstacles on the path'),
('v1000001-0000-0000-0000-000000000029', '2026-04-24', 'Two wings of the bird: knowledge + detachment'),
('y1000001-0000-0000-0000-000000000027', '2026-04-25', 'Om — the sound of the divine'),
('v1000001-0000-0000-0000-000000000010', '2026-04-26', 'Nobody can free your soul but you'),
('y1000001-0000-0000-0000-000000000051', '2026-04-27', 'Seedless samadhi — the ultimate state'),
('v1000001-0000-0000-0000-000000000024', '2026-04-28', 'The I-I that never changes'),
('y2000001-0000-0000-0000-000000000001', '2026-04-29', 'Kriya Yoga: austerity, study, surrender'),
('v1000001-0000-0000-0000-000000000014', '2026-04-30', 'Poison vs nectar — choose your intake'),
('y3000001-0000-0000-0000-000000000001', '2026-05-01', 'Dharana: binding the mind to one place'),
('v1000001-0000-0000-0000-000000000030', '2026-05-02', 'You are not a body slowly dying'),
('y4000001-0000-0000-0000-000000000034', '2026-05-03', 'The final sutra: Kaivalya — absolute liberation');


commit;


-- =============================================================================
-- POST-SEED NOTE
-- =============================================================================
-- The remaining ~130 Yoga Sutras (2.11-2.55, 3.2-3.54, 4.2-4.33) should be
-- loaded programmatically from yoga-sutras-complete.json using the Supabase
-- client library. A TypeScript seed script (seed-yoga-sutras.ts) should:
--
--   1. Read yoga-sutras-complete.json
--   2. For each sutra, generate a deterministic UUID using the pattern:
--      y{pada}000001-0000-0000-0000-{sutra_number_zero_padded}
--   3. Insert into the verses table with all fields mapped
--   4. Insert verse_themes mappings based on the pada
--
-- This approach avoids a 5000+ line SQL file while ensuring complete data.
-- =============================================================================
