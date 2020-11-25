# frozen_string_literal: true

# Helpers to figure out if MARC usage is "standard" or a local practice
# rubocop:disable Metrics/ClassLength
class MarcRules
  COMMON_FIELDS = {
    'LDR' => nil,
    '001' => nil,
    '003' => nil,
    '005' => nil,
    '006' => nil,
    '007' => nil,
    '008' => nil,
    '010' => %w[a b z 8],
    '013' => %w[a b c d e f 6 8],
    '015' => %w[a q z 2 6 8],
    '016' => %w[a z 2 8],
    '017' => %w[a b d i z 2 6 8],
    '018' => %w[a 6 8],
    '020' => %w[a c q z 6 8],
    '022' => %w[a l m y z 2 6 8],
    '024' => %w[a c d q z 2 6 8],
    '025' => %w[a 8],
    '026' => %w[a b c d e 2 5 6 8],
    '027' => %w[a q z 6 8],
    '028' => %w[a b q 6 8],
    '030' => %w[a z 6 8],
    '031' => %w[a b c d e g m n o p q r s t u y z 2 6 8],
    '032' => %w[a b 6 8],
    '033' => %w[a b c p 0 2 3 6 8],
    '034' => %w[a b c d e f g h j k m n p r s t x y z 0 2 3 6 8],
    '035' => %w[a z 6 8],
    '036' => %w[a b 6 8],
    '037' => %w[a b c f g n 3 5 6 8],
    '038' => %w[a 6 8],
    '040' => %w[a b c d e 6 8],
    '041' => %w[a b d e f g h j k m n 2 6 8],
    '042' => ['a'],
    '043' => %w[a b c 0 2 6 8],
    '044' => %w[a b c 2 6 8],
    '045' => %w[a b c 6 8],
    '046' => %w[a b c d e j k l m n o p 2 6 8],
    '047' => %w[a 2 8],
    '048' => %w[a b 2 8],
    '050' => %w[a b 3 6 8],
    '051' => %w[a b c 8],
    '052' => %w[a b d 2 6 8],
    '055' => %w[a b 0 2 6 8],
    '060' => %w[a b 0 8],
    '061' => %w[a b c 8],
    '066' => %w[a b c],
    '070' => %w[a b 0 8],
    '071' => %w[a b c 8],
    '072' => %w[a x 2 6 8],
    '074' => %w[a z 8],
    '080' => %w[a b x 2 6 8],
    '082' => %w[a b m q 2 6 8],
    '083' => %w[a c m q y z 2 6 8],
    '084' => %w[a b q 2 6 8],
    '085' => %w[a b c f r s t u v w y z 0 6 8],
    '086' => %w[a z 2 6 8],
    '088' => %w[a z 6 8],
    '100' => %w[a b c d e f g j k l n p q t u 0 4 6 8],
    '110' => %w[a b c d e f g k l n p t u 0 4 6 8],
    '111' => %w[a c d e f g j k l n p q t u 0 4 6 8],
    '130' => %w[a d f g h k l m n o p r s t 0 6 8],
    '210' => %w[a b 2 6 8],
    '222' => %w[a b 6 8],
    '240' => %w[a d f g h k l m n o p r s 0 6 8],
    '242' => %w[a b c h n p y 6 8],
    '243' => %w[a d f g h k l m n o p r s 6 8],
    '245' => %w[a b c f g h k n p s 6 8],
    '246' => %w[a b f g h i n p 5 6 8],
    '247' => %w[a b f g h n p x 6 8],
    '250' => %w[a b 3 6 8],
    '254' => %w[a 6 8],
    '255' => %w[a b c d e f g 6 8],
    '256' => %w[a 6 8],
    '257' => %w[a 0 2 6 8],
    '258' => %w[a b 6 8],
    '260' => %w[a b c e f g 3 6 8],
    '263' => %w[a 6 8],
    '264' => %w[a b c 3 6 8],
    '270' => %w[a b c d e f g h i j k l m n p q r z 4 6 8],
    '300' => %w[a b c e f g 3 6 8],
    '306' => %w[a 6 8],
    '307' => %w[a b 6 8],
    '310' => %w[a b 6 8],
    '321' => %w[a b 6 8],
    '336' => %w[a b 0 2 3 6 8],
    '337' => %w[a b 0 2 3 6 8],
    '338' => %w[a b 0 2 3 6 8],
    '340' => %w[a b c d e f g h i j k m n o 0 2 3 6 8],
    '342' => %w[a b c d e f g h i j k l m n o p q r s t u v w 2 6 8],
    '343' => %w[a b c d e f g h i 6 8],
    '344' => %w[a b c d e f g h 0 2 3 6 8],
    '345' => %w[a b 0 2 3 6 8],
    '346' => %w[a b 0 2 3 6 8],
    '347' => %w[a b c d e f 0 2 3 6 8],
    '348' => %w[a b 0 2 3 6 8],
    '351' => %w[a b c 3 6 8],
    '352' => %w[a b c d e f g i q 6 8],
    '355' => %w[a b c d e f g h j 6 8],
    '357' => %w[a b c g 6 8],
    '362' => %w[a z 6 8],
    '363' => %w[a b c d e f g h i j k l m u v x z 6 8],
    '365' => %w[a b c d e f g h i j k m 2 6 8],
    '366' => %w[a b c d e f g j k m 2 6 8],
    '370' => %w[c f g i s t u v 0 2 3 4 6 8],
    '377' => %w[a l 0 2 6 8],
    '380' => %w[a 0 2 6 8],
    '381' => %w[a u v 0 2 6 8],
    '382' => %w[a b d e n p r s t v 0 2 3 6 8],
    '383' => %w[a b c d e 2 6 8],
    '384' => %w[a 6 8],
    '385' => %w[a b m n 0 2 3 6 8],
    '386' => %w[a b i m n 0 2 3 4 6 8],
    '388' => %w[a 0 2 3 6 8],
    '400' => %w[a b c d e f g k l n p t u v x 4 6 8],
    '410' => %w[a b c d e f g k l n p t u v x 4 6 8],
    '411' => %w[a c d e f g k l n p q t u v x 4 6 8],
    '440' => %w[a n p v w x 0 6 8],
    '490' => %w[a l v x 3 6 8],
    '500' => %w[a 3 5 6 8],
    '501' => %w[a 5 6 8],
    '502' => %w[a b c d g o 6 8],
    '504' => %w[a b 6 8],
    '505' => %w[a g r t u 6 8],
    '506' => %w[a b c d e f u 2 3 5 6 8],
    '507' => %w[a b 6 8],
    '508' => %w[a 6 8],
    '510' => %w[a b c u x 3 6 8],
    '511' => %w[a 6 8],
    '513' => %w[a b 6 8],
    '514' => %w[a b c d e f g h i j k m u z 6 8],
    '515' => %w[a 6 8],
    '516' => %w[a 6 8],
    '518' => %w[a d o p 0 2 3 6 8],
    '520' => %w[a b c u 2 3 6 8],
    '521' => %w[a b 3 6 8],
    '522' => %w[a 6 8],
    '524' => %w[a 2 3 6 8],
    '525' => %w[a 6 8],
    '526' => %w[a b c d i x z 5 6 8],
    '530' => %w[a b c d u 3 6 8],
    '533' => %w[a b c d e f m n 3 5 7 6 8],
    '534' => %w[a b c e f k l m n o p t x z 3 6 8],
    '535' => %w[a b c d g 3 6 8],
    '536' => %w[a b c d e f g h 6 8],
    '538' => %w[a i u 3 5 6 8],
    '540' => %w[a b c d u 3 5 6 8],
    '541' => %w[a b c d e f h n o 3 5 6 8],
    '542' => %w[a b c d e f g h i j k l m n o p q r s u 3 6 8],
    '544' => %w[a b c d e n 3 6 8],
    '545' => %w[a b u 6 8],
    '546' => %w[a b 3 6 8],
    '547' => %w[a 6 8],
    '550' => %w[a 6 8],
    '552' => %w[a b c d e f g h i j k l m n o p u z 6 8],
    '555' => %w[a b c d u 3 6 8],
    '556' => %w[a z 6 8],
    '561' => %w[a u 3 5 6 8],
    '562' => %w[a b c d e 3 5 6 8],
    '563' => %w[a u 3 5 6 8],
    '565' => %w[a b c d e 3 6 8],
    '567' => %w[a b 0 2 6 8],
    '580' => %w[a 6 8],
    '581' => %w[a z 3 6 8],
    '583' => %w[a b c d e f h i j k l n o u x z 2 3 5 6 8],
    '584' => %w[a b 3 5 6 8],
    '585' => %w[a 3 5 6 8],
    '586' => %w[a 3 6 8],
    '588' => %w[a 5 6 8],
    '600' => %w[a b c d e f g h j k l m n o p q r s t u v x y z 0 2 3 4 6 8],
    '610' => %w[a b c d e f g h k l m n o p r s t u v x y z 0 2 3 4 6 8],
    '611' => %w[a c d e f g h j k l n p q s t u v x y z 0 2 3 4 6 8],
    '630' => %w[a d e f g h k l m n o p r s t v x y z 0 2 3 4 6 8],
    '647' => %w[a c d g v x y z 0 2 3 6 8],
    '648' => %w[a v x y z 0 2 3 6 8],
    '650' => %w[a b c d e g 4 v x y z 0 2 3 6 8],
    '651' => %w[a e g 4 v x y z 0 2 3 6 8],
    '653' => %w[a 6 8],
    '654' => %w[a b c e v y z 0 2 3 4 6 8],
    '655' => %w[a b c v x y z 0 2 3 5 6 8],
    '656' => %w[a k v x y z 0 2 3 6 8],
    '657' => %w[a v x y z 0 2 3 6 8],
    '658' => %w[a b c d 2 6 8],
    '662' => %w[a b c d e f g h 0 2 4 6 8],
    '700' => %w[a b c d e f g h i j k l m n o p q r s t u x 0 3 4 5 6 8],
    '710' => %w[a b c d e f g h i k l m n o p r s t u x 0 3 4 5 6 8],
    '711' => %w[a c d e f g h i j k l n p q s t u x 0 3 4 5 6 8],
    '720' => %w[a e 4 6 8],
    '730' => %w[a d f g h i k l m n o p r s t x 0 3 5 6 8],
    '740' => %w[a h n p 5 6 8],
    '751' => %w[a e 0 2 3 4 6 8],
    '752' => %w[a b c d e f g h 0 2 4 6 8],
    '753' => %w[a b c 0 2 6 8],
    '754' => %w[a c d x z 0 2 6 8],
    '760' => %w[a b c d g h i m n o s t w x y 4 6 7 8],
    '762' => %w[a b c d g h i m n o s t w x y 4 6 7 8],
    '765' => %w[a b c d g h i k m n o r s t u w x y z 4 6 7 8],
    '767' => %w[a b c d g h i k m n o r s t u w x y z 4 6 7 8],
    '770' => %w[a b c d g h i k m n o r s t u w x y z 4 6 7 8],
    '772' => %w[a b c d g h i k m n o r s t u w x y z 4 6 7 8],
    '773' => %w[a b d g h i k m n o p q r s t u w x y z 3 4 6 7 8],
    '774' => %w[a b c d g h i k m n o r s t u w x y z 4 6 7 8],
    '775' => %w[a b c d e f g h i k m n o r s t u w x y z 4 6 7 8],
    '776' => %w[a b c d g h i k m n o r s t u w x y z 4 6 7 8],
    '777' => %w[a b c d g h i k m n o s t w x y 4 6 7 8],
    '780' => %w[a b c d g h i k m n o r s t u w x y z 4 6 7 8],
    '785' => %w[a b c d g h i k m n o r s t u w x y z 4 6 7 8],
    '786' => %w[a b c d g h i j k m n o p r s t u v w x y z 4 6 7 8],
    '787' => %w[a b c d g h i k m n o r s t u w x y z 4 6 7 8],
    '800' => %w[a b c d e f g h j k l m n o p q r s t u v w x 0 3 4 5 6 7 8],
    '810' => %w[a b c d e f g h k l m n o p r s t u v w x 0 3 4 5 6 7 8],
    '811' => %w[a c d e f g h j k l n p q s t u v w x 0 3 4 5 6 7 8],
    '830' => %w[a d f g h k l m n o p r s t v w x 0 3 5 6 7 8],
    '850' => %w[a 8],
    '852' => %w[a b c d e f g h i j k l m n p q s t u x z 2 3 6 8],
    '856' => %w[a b c d f h i j k l m n o p q r s t u v w x y z 2 3 6 8],
    '880' => %w[6 a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 7 8 9],
    '882' => %w[a i w 6 8],
    '883' => %w[a c d q x u w 0 8],
    '884' => %w[a g k q u],
    '885' => %w[a b c d w x z 0 2 5],
    '886' => %w[a b 2],
    '887' => %w[a 2]
  }.freeze

  def self.common_field?(field)
    COMMON_FIELDS.key?(field)
  end

  def self.common_practice?(field, subfield = nil)
    return true if subfield.nil? && common_field?(field)
    return false unless common_field?(field)

    COMMON_FIELDS[field]&.include?(subfield)
  end
end
# rubocop:enable Metrics/ClassLength
