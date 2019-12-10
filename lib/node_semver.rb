module NodeSemver
  extend self

  # The following Regular Expressions can be used for tokenizing, validating, and parsing Semver version strings.
  src = {}

  # ## Numeric Identifier
  # A single `0`, or a non-zero digit followed by zero or more digits.
  src[:numeric_identifier] = '0|[1-9]\\d*'
  src[:numeric_identifier_loose] = '[0-9]+'

  # ## Non-numeric Identifier
  # Zero or more digits, followed by a letter or hyphen, and then zero or more letters, digits, or hyphens.
  src[:non_numeric_identifier] = '\\d*[a-zA-Z-][a-zA-Z0-9-]*'

  # ## Main Version
  # Three dot-separated numeric identifiers.
  src[:main_version] = '(' + src[:numeric_identifier] + ')\\.(' + src[:numeric_identifier] + ')\\.(' + src[:numeric_identifier] + ')'
  src[:main_version_loose] = '(' + src[:numeric_identifier_loose] + ')\\.(' + src[:numeric_identifier_loose] + ')\\.(' + src[:numeric_identifier_loose] + ')'

  # ## Pre-release Version Identifier
  # A numeric identifier, or a non-numeric identifier.
  src[:prerelease_identifier] = '(?:' + src[:numeric_identifier] + '|' + src[:non_numeric_identifier] + ')'
  src[:prerelease_identifier_loose] = '(?:' + src[:numeric_identifier_loose] + '|' + src[:non_numeric_identifier] + ')'

  # ## Pre-release Version
  # Hyphen, followed by one or more dot-separated pre-release version identifiers.
  src[:prerelease] = '(?:-(' + src[:prerelease_identifier] + '(?:\\.' + src[:prerelease_identifier] + ')*))'
  src[:prerelease_loose] = '(?:-?(' + src[:prerelease_identifier_loose] + '(?:\\.' + src[:prerelease_identifier_loose] + ')*))'

  # ## Build Metadata Identifier
  # Any combination of digits, letters, or hyphens.
  src[:build_identifier] = '[0-9A-Za-z-]+'

  # ## Build Metadata
  # Plus sign, followed by one or more period-separated build metadata identifiers.
  src[:build] = '(?:\\+(' + src[:build_identifier] + '(?:\\.' + src[:build_identifier] + ')*))'

  #  ## Full Version String
  #  A main version, followed optionally by a pre-release version and build metadata.
  #  Note that the only major, minor, patch, and pre-release sections of
  #  the version string are capturing groups.  The build metadata is not a
  #  capturing group, because it should not ever be used in version
  #  comparison.
  FULL_PLAIN = 'v?' + src[:main_version] + src[:prerelease] + '?' + src[:build] + '?'
  src[:full] = '^' + FULL_PLAIN + '$'

  #  like full, but allows v1.2.3 and =1.2.3, which people do sometimes.
  #  also, 1.0.0alpha1 (prerelease without the hyphen) which is pretty common in the npm registry.
  LOOSE_PLAIN = '[v=\\s]*' + src[:main_version_loose] + src[:prerelease_loose] + '?' + src[:build] + '?'
  src[:loose] = '^' + LOOSE_PLAIN + '$'

  src[:gtlt] = '((?:<|>)?=?)'

  #  Something like "2.*" or "1.2.x".
  #  Note that "x.x" is a valid xRange identifier, meaning "any version". Only the first item is strictly required.
  src[:xrange_identifier] = src[:numeric_identifier] + '|x|X|\\*'
  src[:xrange_identifier_loose] = src[:numeric_identifier_loose] + '|x|X|\\*'
  src[:xrange_plain] = '[v=\\s]*(' + src[:xrange_identifier] + ')(?:\\.(' + src[:xrange_identifier] + ')(?:\\.(' + src[:xrange_identifier] + ')(?:' + src[:prerelease] + ')?' + src[:build] + '?)?)?'
  src[:xrange_plain_loose] = '[v=\\s]*(' + src[:xrange_identifier_loose] + ')(?:\\.(' + src[:xrange_identifier_loose] + ')(?:\\.(' + src[:xrange_identifier_loose] + ')(?:' + src[:prerelease_loose] + ')?' + src[:build] + '?)?)?'
  src[:xrange] = '^' + src[:gtlt] + '\\s*' + src[:xrange_plain] + '$'
  src[:xrange_loose] = '^' + src[:gtlt] + '\\s*' + src[:xrange_plain_loose] + '$'

  #  Tilde ranges.
  #  Meaning is "reasonably at or greater than"
  src[:lone_tilde] = '(?:~>?)'
  src[:tilde_trim] = '(\\s*)' + src[:lone_tilde] + '\\s+'

  src[:tilde] = '^' + src[:lone_tilde] + src[:xrange_plain] + '$'
  src[:tilde_loose] = '^' + src[:lone_tilde] + src[:xrange_plain_loose] + '$'

  #  Caret ranges.
  #  Meaning is "at least and backwards compatible with"
  src[:lone_caret] = '(?:\\^)'
  src[:caret_trim] = '(\\s*)' + src[:lone_caret] + '\\s+'

  src[:caret] = '^' + src[:lone_caret] + src[:xrange_plain] + '$'
  src[:caret_loose] = '^' + src[:lone_caret] + src[:xrange_plain_loose] + '$'

  #  A simple gt/lt/eq thing, or just "" to indicate "any version"
  src[:comparator_loose] = '^' + src[:gtlt] + '\\s*(' + LOOSE_PLAIN + ')$|^$'
  src[:comparator] = '^' + src[:gtlt] + '\\s*(' + FULL_PLAIN + ')$|^$'

  #  An expression to strip any whitespace between the gtlt and the thing it modifies, so that `> 1.2.3` ==> `>1.2.3`
  src[:comparator_trim] = '(\\s*)' + src[:gtlt] + '\\s*(' + LOOSE_PLAIN + '|' + src[:xrange_plain] + ')'

  #  Something like `1.2.3 - 1.2.4`
  #  Note that these all use the loose form, because they'll be  checked against either the strict or loose comparator form later.
  src[:hyphen_range] = '^\\s*(' + src[:xrange_plain] + ')\\s+-\\s+(' + src[:xrange_plain] + ')\\s*$'
  src[:hyphen_range_loose] = '^\\s*(' + src[:xrange_plain_loose] + ')\\s+-\\s+(' + src[:xrange_plain_loose] + ')\\s*$'

  #  Star ranges basically just allow anything at all.
  src[:star] = '(<|>)?=?\\s*\\*'

  # version name recovery for convinient
  src[:recovery_version_name] = '^v?(%s)(?:\\.(%s))?%s?' % [src[:numeric_identifier], src[:numeric_identifier], src[:prerelease_loose]]

  @@regexps = {
    :tilde_trim => Regexp.new(src[:tilde_trim], Regexp::MULTILINE),
    :caret_trim => Regexp.new(src[:caret_trim], Regexp::MULTILINE),
    :comparator_trim => Regexp.new(src[:comparator_trim], Regexp::MULTILINE),
  }

  #  Compile to actual @@regexps objects.
  #  All are flag-free, unless they were created above with a flag.
  src.each do |k, v|
    unless @@regexps.key?(k)
      @@regexps[k] = Regexp.new(v)
    end
  end

  def get_regex(key)
    @@regexps[key]
  end

  def parse(version, loose)
    r = get_regex(loose ? :loose : :full)
    m = r.search(version)
    m ? make_semver(version, loose) : nil
  end

  def valid(version, loose)
    v = parse(version, loose)
    v.version ? v : nil
  end

  def clean(version, loose)
    s = parse(version, loose)
    s ? s.version : nil
  end

  def isnumeric?(s)
    !/^\d+$/.match(s).nil?
  end

  def make_semver(version, loose)
    if version.instance_of? Semver
      version.loose == loose ? version : Semver.new(version.version, loose)
    elsif version.instance_of? String
      Semver.new(version, loose)
    else
      raise ArgumentError.new("Version must be a string, but was #{version.inspect}")
    end
  end

  alias semver make_semver

  class Semver
    attr_reader :raw, :loose, :version, :major, :minor, :patch, :prerelease, :build, :micro_versions

    def initialize(version, loose)
      @raw = version
      @loose = loose
      @build = []
      @micro_versions = []

      v = version.strip
      m = NodeSemver.get_regex(loose ? :loose : :full).match(v)
      if m.nil?
        if not loose
          raise ArgumentError.new("Invalid version: #{version.inspect}")
        end

        m = NodeSemver.get_regex(:recovery_version_name).match(v)
        if m.nil?
          raise ArgumentError.new("Invalid version: #{version.inspect}")
        end

        @major = m[1].to_i
        @minor = m[2].to_i
        @patch = 0
        if m[3].nil?
          # this is not same behaviour  node's semver (see: https://github.com/podhmo/python-semver/issues/15)
          @prerelease = v[m.end(0)..v.length].split('.').select{|x| !x.empty?}
          if !@prerelease.empty? and NodeSemver.isnumeric?(@prerelease[0])
            @patch = @prerelease[0].to_i
            @prerelease = @prerelease[1..prerelease.length]
          end

          prerelease = []
          for id in @prerelease do
            if id.include?("-")
              other = prerelease
              ks = id.split("-")
            elsif id.include?("+")
              other = @build
              ks = id.split("+")
            else
              other = nil
              ks = [id]
            end
            for k in ks do
              if NodeSemver.isnumeric?(k)
                @micro_versions.push(k.to_i)
              elsif other.nil?
                raise ArgumentError.new("Invalid version: #{version.inspect}")
              else
                other.push(k)
              end
            end
          end
          @prerelease = prerelease
          @prerelease = @prerelease.map{|id| NodeSemver.isnumeric?(id) ? id.to_i : id}
        else
          @prerelease = m[3].split(".").map{|id| NodeSemver.isnumeric?(id) ? id.to_i : id}
        end
      else
        #  these are actually numbers
        @major = m[1].to_i
        @minor = m[2].to_i
        @patch = m[3].to_i
        #  numberify any prerelease numeric ids
        @prerelease = (m[4] or "").split(".").map{|id| NodeSemver.isnumeric?(id) ? id.to_i : id}

        if !m[5].nil?
          @build = m[5].split(".")
        end
      end

      @version = format
    end

    def format
      @version = "#{@major}.#{@minor}.#{@patch}"
      if @prerelease.length > 0
        @version += '-' + @prerelease.map(&:to_s).join('.')
      elsif !@micro_versions.empty?
        @version += '.' + @micro_versions.map(&:to_s).join('.')
      end
      @version
    end

    def to_s
      "#<NodeSemver Semver #{@version.inspect}>"
    end

    def compare(other)
      if not other.instance_of? Semver
        other = NodeSemver.make_semver(other, @loose)
      end
      result = compare_main(other)
      if result.zero?
        result = compare_pre(other)
      end
      if result.zero?
        result = compare_micro(other)
      end
      result
    end

    def compare_main(other)
      if not other.instance_of? Semver
        other = NodeSemver.make_semver(other, @loose)
      end
      result = NodeSemver.compare_identifiers(@major.to_s, other.major.to_s)
      if result.zero?
        result = NodeSemver.compare_identifiers(@minor.to_s, other.minor.to_s)
      end
      if result.zero?
        result = NodeSemver.compare_identifiers(@patch.to_s, other.patch.to_s)
      end
      result
    end

    def compare_pre(other)
      if not other.instance_of? Semver
        other = NodeSemver.make_semver(other, @loose)
      end

      #  NOT having a prerelease is > having one
      is_self_more_than_zero = @prerelease.length > 0
      is_other_more_than_zero = other.prerelease.length > 0

      if not is_self_more_than_zero and is_other_more_than_zero
        return 1
      elsif is_self_more_than_zero and not is_other_more_than_zero
        return -1
      elsif not is_self_more_than_zero and not is_other_more_than_zero
        return 0
      end

      i = 0
      while true
        a = @prerelease[i]
        b = other.prerelease[i]
        if a.nil? and b.nil?
          return 0
        elsif b.nil?
          return 1
        elsif a.nil?
          return -1
        elsif a != b
          return NodeSemver.compare_identifiers(a.to_s, b.to_s)
        end
        i += 1
      end
    end

    def compare_micro(other)
      if @micro_versions == other.micro_versions
        0
      elsif @micro_versions < other.micro_versions
        -1
      else
        1
      end
    end

    def inc(release, identifier=nil)
      case release
      when 'premajor'
        @prerelease = []
        @patch = 0
        @minor = 0
        @major += 1
        inc('pre', identifier)
      when "preminor"
        @prerelease = []
        @patch = 0
        @minor += 1
        inc('pre', identifier)
      when "prepatch"
        # If this is already a prerelease, it will bump to the next version drop any prereleases
        # that might already exist, since they are not relevant at this point.
        @prerelease = []
        inc('patch', identifier)
        inc('pre', identifier)
      when 'prerelease'
        # If the input is a non-prerelease version, this acts the same as prepatch.
        if @prerelease.length == 0
          inc("patch", identifier)
        end
        inc("pre", identifier)
      when "major"
        # If this is a pre-major version, bump up to the same major version. Otherwise increment major.
        # 1.0.0-5 bumps to 1.0.0
        # 1.1.0 bumps to 2.0.0
        if @minor != 0 or @patch != 0 or @prerelease.length == 0
          @major += 1
        end
        @minor = 0
        @patch = 0
        @prerelease = []
      when "minor"
        # If this is a pre-minor version, bump up to the same minor version. Otherwise increment minor.
        # 1.2.0-5 bumps to 1.2.0
        # 1.2.1 bumps to 1.3.0
        if @patch != 0 or @prerelease.length == 0
          @minor += 1
        end
        @patch = 0
        @prerelease = []
      when "patch"
        #  If this is not a pre-release version, it will increment the patch.
        #  If it is a pre-release it will bump up to the same patch version.
        #  1.2.0-5 patches to 1.2.0
        #  1.2.0 patches to 1.2.1
        if @prerelease.length == 0
          @patch += 1
        end
        @prerelease = []
      when "pre"
        #  This probably shouldn't be used publically.
        #  1.0.0 "pre" would become 1.0.0-0 which is the wrong direction.
        if @prerelease.length == 0
          @prerelease = [0]
        else
          i = @prerelease.length - 1
          while i >= 0
            if @prerelease[i].instance_of? Fixnum
              @prerelease[i] += 1
              i -= 2
            end
            i -= 1
          end
        end
        if not identifier.nil?
          # 1.2.0-beta.1 bumps to 1.2.0-beta.2,
          # 1.2.0-beta.fooblz or 1.2.0-beta bumps to 1.2.0-beta.0
          if @prerelease[0] != identifier or not @prerelease[1].instance_of? Fixnum
            @prerelease = [identifier, 0]
          end
        end
      else
        raise ArgumentError.new("Invalid increment argument: #{release.inspect}")
      end

      format
    end
  end

  def inc(version, release, loose, identifier=nil)
    begin
      make_semver(version, loose).inc(release, identifier)
    rescue
    end
  end

  def compare_identifiers(a, b)
    anum = isnumeric?(a)
    bnum = isnumeric?(b)

    if anum and bnum
      a = a.to_i
      b = b.to_i
    end

    if anum and !bnum
      -1
    elsif bnum and !anum
      1
    elsif a < b
      -1
    elsif a > b
      1
    else
      0
    end
  end

  def rcompare_identifiers(a, b)
    compare_identifiers(b, a)
  end

  def compare(a, b, loose)
    make_semver(a, loose).compare(b)
  end

  def compare_loose(a, b)
    compare(a, b, true)
  end

  def rcompare(a, b, loose)
    compare(b, a, loose)
  end

  # Sort key for prereleases.
  # Precedence for two pre-release versions with the same major, minor, and patch version MUST be determined by comparing each
  # dot separated identifier from left to right until a difference is found as follows:
  # * Identifiers consisting of only digits are compared numerically, otherwise they're compared in ASCII sort order.
  # * Numeric identifiers always have lower precedence than non-numeric identifiers.
  # * A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal.
  def _prerelease_key(prerelease)
    prerelease.map {|e| (e.instance_of? Fixnum) ? ['', e] : [e]}
  end

  {'loose'=>true, 'full'=>false}.each do |k, loose|
    define_method(k + '_key_function') do |version|
      v = make_semver(version, loose)
      key = [v.major, v.minor, v.patch]
      if !v.micro_versions.nil? and !v.micro_versions.empty?
        key = key + v.micro_versions
      end
      if !v.prerelease.nil? and !v.prerelease.empty?
        key = key + [0] + _prerelease_key(v.prerelease)
      else
        key = key + [1]  # NOT having a prerelease is > having one
      end
    end
  end

  def sort(list, loose)
    list.sort_by {|x| loose ? loose_key_function(x) : full_key_function(x)}
  end

  def rsort(list, loose)
    sort(list, loose).reverse
  end

  def gt(a, b, loose)
    compare(a, b, loose) > 0
  end

  def lt(a, b, loose)
    compare(a, b, loose) < 0
  end

  def eq(a, b, loose)
    compare(a, b, loose) == 0
  end

  def neq(a, b, loose)
    compare(a, b, loose) != 0
  end

  def gte(a, b, loose)
    compare(a, b, loose) >= 0
  end

  def lte(a, b, loose)
    compare(a, b, loose) <= 0
  end

  def cmp(a, op, b, loose)
    case op
    when "==="
      a == b
    when "!=="
      a != b
    when "", "=", "=="
      eq(a, b, loose)
    when "!="
      neq(a, b, loose)
    when ">"
      gt(a, b, loose)
    when ">="
      gte(a, b, loose)
    when "<"
      lt(a, b, loose)
    when "<="
      lte(a, b, loose)
    else
      raise ArgumentError.new("Invalid operator: #{op.inspect}")
    end
  end

  def make_comparator(comp, loose)
    if comp.instance_of? Comparator and comp.loose == loose
      comp
    elsif comp.instance_of? Comparator
      Comparator.new(comp.value, loose)
    else
      Comparator.new(comp, loose)
    end
  end

  alias comparator make_comparator

  class Comparator
    attr_reader :semver, :loose, :value, :operator

    def initialize(comp, loose)
      @loose = loose
      parse(comp)
      @value = @semver == :any ? "" : @operator + @semver.version
    end

    def parse(comp)
      r = NodeSemver.get_regex(@loose ? :comparator_loose : :comparator)
      m = r.match(comp)
      if m.nil?
        raise ArgumentError.new("Invalid comparator: #{comp.inspect}")
      end

      @operator = m[1]
      # if it literally is just '>' or '' then allow anything.
      @semver = m[2].nil? ? :any : NodeSemver.make_semver(m[2], @loose)
    end

    def to_s
      '#<NodeSemver Comparator #{@value.inspect}>'
    end

    def test(version)
      if @semver == :any
        return true
      end
      NodeSemver.cmp(version, @operator, @semver, @loose)
    end
  end

  def make_range(range, loose)
    if range.instance_of? Range
      range.loose == loose ? range : Range.new(range.range, loose)
    elsif range.instance_of? String
      Range.new(range, loose)
    else
      raise ArgumentError.new("Range must be a string, but was #{range.inspect}")
    end
  end

  class Range
    attr_reader :loose, :set, :range

    def initialize(range, loose, _split_rx=/\s*\|\|\s*/)
      @loose = loose
      @set = range.split(_split_rx)
      @set.push('') if @set.empty?
      @set.push('') if range.strip == '||'
      @set = @set.map{|r| parse_range(r)}.select{|r| !r.empty?}
      if @set.empty?
        raise ArgumentError.new("Invalid version range: #{range.inspect}")
      end
      format
    end

    def to_s
      "#<NodeSemver Range #{@range.inspect}>"
    end

    def format
      @range = @set.map{|comps| comps.map(&:value).join(' ').strip}.join('||').strip
    end

    def parse_range(range)
      range = range.strip

      #  `1.2.3 - 1.2.4` => `>=1.2.3 <=1.2.4`
      #  `1.2.3 - 3.4` => `>=1.2.0 <3.5.0` (Any 3.4.x will do)
      #  `1.2 - 3.4` => `>=1.2.0 <3.5.0`
      hyphen_range_regex = NodeSemver.get_regex(@loose ? :hyphen_range_loose : :hyphen_range)
      range = range.gsub(hyphen_range_regex) do
        match = Regexp.last_match
        src, src_major, src_minor, src_patch, src_prerelease, src_build = *match[1, 6]
        dst, dst_major, dst_minor, dst_patch, dst_prerelease, dst_build = *match[7, 12]

        if NodeSemver.is_x(src_major)
          src = ''
        elsif NodeSemver.is_x(src_minor)
          src = '>=' + "#{src_major}.0.0"
        elsif NodeSemver.is_x(src_patch)
          src = '>=' + "#{src_major}.#{src_minor}.0"
        else
          src = '>=' + src
        end

        if NodeSemver.is_x(dst_major)
          src
        elsif NodeSemver.is_x(dst_minor)
          src + ' <' + "#{dst_major.to_i+1}.0.0"
        elsif NodeSemver.is_x(dst_patch)
          src + ' <' + "#{dst_major}.#{dst_minor.to_i+1}.0"
        elsif dst_prerelease.nil? or dst_prerelease.empty?
          src + ' <=' + dst
        else
          src + ' <=' + "#{dst_major}.#{dst_minor}.#{dst_patch}-#{dst_prerelease}"
        end
      end

      # Trim comparator, tilde, carets, and spaces
      #  `> 1.2.3 < 1.2.5` => `>1.2.3 <1.2.5`
      range = range.gsub(NodeSemver.get_regex(:comparator_trim), '\1\2\3')
      range = range.gsub(NodeSemver.get_regex(:tilde_trim), '\1~')
      range = range.gsub(NodeSemver.get_regex(:caret_trim), '\1^')
      range = range.gsub(/\s+/, ' ')

      # At this point, the range is completely trimmed and ready to be split into comparators.
      set = range.split(' ').map{|comp| NodeSemver.parse_comparator(comp, @loose)}.join(' ').split(/\s+/)
      set = set.empty? ? [''] : set
      if @loose
        set.select! {|comp| !NodeSemver.get_regex(:comparator_loose).match(comp).nil?}
      end
      set.map! {|comp| NodeSemver.make_comparator(comp, @loose)}
    end

    def test(version, include_prerelease=false)
      if !version.instance_of? Semver and (!version or version.nil? or version.empty?)
        return false
      elsif version.instance_of? String
        version = NodeSemver.make_semver(version, @loose)
      end
      @set.any? {|x| NodeSemver.test_set(x, version, include_prerelease)}
    end
  end

  #  Mostly just for testing and legacy API reasons
  def to_comparators(range, loose)
    r = make_range(range, loose)
    r.set.map do |comp|
      set = comp.map(&:value).join(' ').strip.split(' ')
      set.empty? ? [''] : set
    end
  end

  #  Comprised of xranges, tildes, stars, and gtlt's at this point.
  #  Already replaced the hyphen ranges turn into a set of JUST comparators.
  def parse_comparator(comp, loose)
    comp = replace_carets(comp, loose)
    comp = replace_tildes(comp, loose)
    comp = replace_xranges(comp, loose)
    comp = replace_stars(comp, loose)
    comp
  end

  def is_x(id)
    id.nil? or id == "" or id.downcase == "x" or id == "*"
  end

  #  ~, ~> --> * (any, kinda silly)
  #  ~2, ~2.x, ~2.x.x, ~>2, ~>2.x ~>2.x.x --> >=2.0.0 <3.0.0
  #  ~2.0, ~2.0.x, ~>2.0, ~>2.0.x --> >=2.0.0 <2.1.0
  #  ~1.2, ~1.2.x, ~>1.2, ~>1.2.x --> >=1.2.0 <1.3.0
  #  ~1.2.3, ~>1.2.3 --> >=1.2.3 <1.3.0
  #  ~1.2.0, ~>1.2.0 --> >=1.2.0 <1.3.0
  def replace_tildes(comp, loose)
    comp.strip.split(/\s+/).map{|c| replace_tilde(c, loose)}.join(' ')
  end

  def replace_tilde(comp, loose)
    tilde_regex = get_regex(loose ? :tilde_loose : :tilde)
    comp.gsub(tilde_regex) do
      m = Regexp.last_match
      major, minor, patch, prerelease, build = *m[1, 5]
      if is_x(major)
        ''
      elsif is_x(minor)
        ">=#{major}.0.0 <#{major.to_i+1}.0.0"
      elsif is_x(patch)
        # ~1.2 == >=1.2.0 <1.3.0
        ">=#{major}.#{minor}.0 <#{major}.#{minor.to_i+1}.0"
      elsif prerelease.nil? or prerelease.empty?
        # ~1.2.3 == >=1.2.3 <1.3.0
        ">=#{major}.#{minor}.#{patch} <#{major}.#{minor.to_i+1}.0"
      else
        prerelease = (prerelease[0] != '-' ? '-' : '') + prerelease
        ">=#{major}.#{minor}.#{patch}#{prerelease} <#{major}.#{minor.to_i+1}.0"
      end
    end
  end

  #  ^ --> * (any, kinda silly)
  #  ^2, ^2.x, ^2.x.x --> >=2.0.0 <3.0.0
  #  ^2.0, ^2.0.x --> >=2.0.0 <3.0.0
  #  ^1.2, ^1.2.x --> >=1.2.0 <2.0.0
  #  ^1.2.3 --> >=1.2.3 <2.0.0
  #  ^1.2.0 --> >=1.2.0 <2.0.0
  def replace_carets(comp, loose)
    comp.strip.split(/\s+/).map{|c| replace_caret(c, loose)}.join(' ')
  end

  def replace_caret(comp, loose)
    caret_regex = get_regex(loose ? :caret_loose : :caret)
    comp.gsub(caret_regex) do
      m = Regexp.last_match
      major, minor, patch, prerelease, build = *m[1, 5]
      patch = patch or ''

      if is_x(major)
        ''
      elsif is_x(minor)
        ">=#{major}.0.0 <#{major.to_i+1}.0.0"
      elsif is_x(patch)
        if major != '0'
          ">=#{major}.#{minor}.0 <#{major.to_i+1}.0.0"
        else
          ">=0.#{minor}.0 <0.#{minor.to_i+1}.0"
        end
      elsif prerelease.nil? or prerelease.empty?
        if major != '0'
          ">=#{major}.#{minor}.#{patch} <#{major.to_i+1}.0.0"
        elsif minor != '0'
          ">=0.#{minor}.#{patch} <0.#{minor.to_i+1}.0"
        else
          ">=0.0.#{patch} <0.0.#{patch.to_i+1}"
        end
      else
        prerelease = (prerelease[0] != '-' ? '-' : '') + prerelease
        if major != '0'
          ">=#{major}.#{minor}.#{patch}#{prerelease} <#{major.to_i+1}.0.0"
        elsif minor != '0'
          ">=0.#{minor}.#{patch}#{prerelease} <0.#{minor.to_i+1}.0"
        else
          ">=0.0.#{patch}#{prerelease} <0.0.#{patch.to_i+1}"
        end
      end
    end
  end

  def replace_xranges(comp, loose)
    comp.strip.split(/\s+/).map{|c| replace_xrange(c, loose)}.join(' ')
  end

  def replace_xrange(comp, loose)
    xrange_regex = get_regex(loose ? :xrange_loose : :xrange)
    comp.strip.gsub(xrange_regex) do
      m = Regexp.last_match
      operator, major, minor, patch, prerelease, build = *m[1, 6]

      major_x = is_x(major)
      minor_x = (major_x or is_x(minor))
      patch_x = (minor_x or is_x(patch))
      any_x = patch_x

      operator = "" if (operator == "=" and any_x)

      if major_x
        # nothing is allowed
        ['>', '<'].include?(operator) ? '<0.0.0' : '*'
      elsif (operator.length > 0) and any_x
        # replace X with 0, and then append the -0 min-prerelease
        minor = '0' if minor_x
        patch = '0' if patch_x
        if operator == ">"
          #  >1 => >=2.0.0
          #  >1.2 => >=1.3.0
          #  >1.2.3 => >= 1.2.4
          operator = ">="
          if minor_x
            major, minor, patch = (major.to_i + 1).to_s, '0', '0'
          elsif patch_x
            major, minor, patch = major, (minor.to_i + 1).to_s, '0'
          end
        elsif operator == '<='
          # <=0.7.x is actually <0.8.0, since any 0.7.x should pass.
          # Similarly, <=7.x is actually <8.0.0, etc.
          operator = '<'
          if minor_x
            major = (major.to_i + 1).to_s
          else
            minor = (minor.to_i + 1).to_s
          end
        else
          if minor_x
            minor, patch = '0', '0'
          elsif patch_x
            minor, patch = minor, '0'
          end
        end
        "#{operator}#{major}.#{minor}.#{patch}"
      elsif minor_x
        ">=#{major}.0.0 <#{major.to_i+1}.0.0"
      elsif patch_x
        ">=#{major}.#{minor}.0 <#{major}.#{minor.to_i+1}.0"
      else
        m[0]
      end
    end
  end

  # Because * is AND-ed with everything else in the comparator, and '' means "any version", just remove the *s entirely.
  def replace_stars(comp, loose)
    # Looseness is ignored here. star is always as loose as it gets!
    comp.strip.gsub(get_regex(:star), '')
  end

  def test_set(set, version, include_prerelease=false)
    if set.any?{|e| not e.test(version)}
      return false
    end

    if version.prerelease.empty? or include_prerelease
      return true
    end

    # Find the set of versions that are allowed to have prereleases
    # For example, `^1.2.3-pr.1` desugars to ``>=1.2.3-pr.1 <2.0.0` so `1.2.3-pr.2` should pass.
    # However, `1.2.4-alpha.notready` should NOT be allowed, even though it's within the range set by the comparators.
    for e in set do
      if e.semver != :any and !e.semver.prerelease.empty?
        if e.semver.major == version.major and e.semver.minor == version.minor and e.semver.patch == version.patch
          return true
        end
      end
    end

    # Version has a -pre, but it's not one of the ones we like.
    false
  end

  def satisfies(version, range, loose=false, include_prerelease=false)
    begin
      range = make_range(range, loose)
    rescue ArgumentError => e
      return false
    end
    range.test(version, include_prerelease)
  end

  {'min'=>1, 'max'=>-1}.each do |k, direction|
    define_method(k + '_satisfying') do |versions, range, loose=false, include_prerelease=false|
      begin
        range_obj = make_range(range, loose)
      rescue ArgumentError
        return nil
      end

      a, b = nil, nil
      for v in versions do
        if range_obj.test(v, include_prerelease) and (a.nil? or b.compare(v) == direction)
          a = v
          b = make_semver(a, loose)
        end
      end
      a
    end
  end

  def valid_range(range, loose)
    begin
      result = make_range(range, loose).range
      result.empty? ? '*' : result
    rescue ArgumentError
    end
  end

  #  Determine if version is less or greater than all the versions possible in the range
  {'ltr'=>'<', 'gtr'=>'>'}.each do |method_name, operator|
    define_method method_name do |version, range, loose|
      version = make_semver(version, loose)
      range = make_range(range, loose)
  
      if operator == '>'
        alias gtfn gt
        alias ltefn lte
        alias ltfn lt
        comp = '>'
        ecomp = '>='
      elsif operator == '<'
        alias gtfn lt
        alias ltefn gte
        alias ltfn gt
        comp = '<'
        ecomp = '<='
      else
        raise ArgumentError.new("Must provide a operator val of '<' or '>'")
      end
  
      #  If it satisifes the range it is not outside
      if satisfies(version, range, loose)
        return false
      end
  
      #  From now on, variable terms are as if we're in "gtr" mode.
      #  but note that everything is flipped for the "ltr" function.
      for comparators in range.set do
        high = nil
        low = nil
        for comparator in comparators do
          high = (high or comparator)
          low = (low or comparator)
          if gtfn(comparator.semver, high.semver, loose)
            high = comparator
          elsif ltfn(comparator.semver, low.semver, loose)
            low = comparator
          end
        end
      end
  
      #  If the edge version comparator has a operator then our version isn't outside it
      if high.operator == comp or high.operator == ecomp
        false
      #  If the lowest version comparator has an operator and our version is less than it then it isn't higher than the range
      elsif (not low.operator or low.operator == comp) and ltefn(version, low.semver, loose)
        false
      elsif low.operator == ecomp and ltfn(version, low.semver, loose)
        false
      else
        true
      end
    end
  end

end
