require 'node_semver'

RSpec.describe(NodeSemver, '#test_comparators') do
  def self.run_test(range, expected)
    it "range=#{range.inspect}, loose=false" do
      expect(NodeSemver.to_comparators(range, false)).to(eq(expected))
    end
  end
  run_test('1.0.0 - 2.0.0', [['>=1.0.0', '<=2.0.0']])
  run_test('1.0.0', [['1.0.0']])
  run_test('>=*', [['']])
  run_test('', [['']])
  run_test('*', [['']])
  run_test('>=1.0.0', [['>=1.0.0']])
  run_test('>1.0.0', [['>1.0.0']])
  run_test('<=2.0.0', [['<=2.0.0']])
  run_test('1', [['>=1.0.0', '<2.0.0']])
  run_test('<2.0.0', [['<2.0.0']])
  run_test('>= 1.0.0', [['>=1.0.0']])
  run_test('>=  1.0.0', [['>=1.0.0']])
  run_test('>=   1.0.0', [['>=1.0.0']])
  run_test('> 1.0.0', [['>1.0.0']])
  run_test('>  1.0.0', [['>1.0.0']])
  run_test('<=   2.0.0', [['<=2.0.0']])
  run_test('<= 2.0.0', [['<=2.0.0']])
  run_test('<=  2.0.0', [['<=2.0.0']])
  run_test('<    2.0.0', [['<2.0.0']])
  run_test("<\t2.0.0", [['<2.0.0']])
  run_test('>=0.1.97', [['>=0.1.97']])
  run_test('0.1.20 || 1.2.4', [['0.1.20'], ['1.2.4']])
  run_test('>=0.2.3 || <0.0.1', [['>=0.2.3'], ['<0.0.1']])
  run_test('||', [[''], ['']])
  run_test('2.x.x', [['>=2.0.0', '<3.0.0']])
  run_test('1.2.x', [['>=1.2.0', '<1.3.0']])
  run_test('1.2.x || 2.x', [['>=1.2.0', '<1.3.0'], ['>=2.0.0', '<3.0.0']])
  run_test('x', [['']])
  run_test('2.*.*', [['>=2.0.0', '<3.0.0']])
  run_test('1.2.*', [['>=1.2.0', '<1.3.0']])
  run_test('1.2.* || 2.*', [['>=1.2.0', '<1.3.0'], ['>=2.0.0', '<3.0.0']])
  run_test('2', [['>=2.0.0', '<3.0.0']])
  run_test('2.3', [['>=2.3.0', '<2.4.0']])
  run_test('~2.4', [['>=2.4.0', '<2.5.0']])
  run_test('~>3.2.1', [['>=3.2.1', '<3.3.0']])
  run_test('~1', [['>=1.0.0', '<2.0.0']])
  run_test('~>1', [['>=1.0.0', '<2.0.0']])
  run_test('~> 1', [['>=1.0.0', '<2.0.0']])
  run_test('~1.0', [['>=1.0.0', '<1.1.0']])
  run_test('~ 1.0', [['>=1.0.0', '<1.1.0']])
  run_test('~ 1.0.3', [['>=1.0.3', '<1.1.0']])
  run_test('~> 1.0.3', [['>=1.0.3', '<1.1.0']])
  run_test('<1', [['<1.0.0']])
  run_test('< 1', [['<1.0.0']])
  run_test('>=1', [['>=1.0.0']])
  run_test('>= 1', [['>=1.0.0']])
  run_test('<1.2', [['<1.2.0']])
  run_test('< 1.2', [['<1.2.0']])
  run_test('1 2', [['>=1.0.0', '<2.0.0', '>=2.0.0', '<3.0.0']])
  run_test('1.2 - 3.4.5', [['>=1.2.0', '<=3.4.5']])
  run_test('1.2.3 - 3.4', [['>=1.2.3', '<3.5.0']])
  run_test('1.2.3 - 3', [['>=1.2.3', '<4.0.0']])
  run_test('>*', [['<0.0.0']])
  run_test('<*', [['<0.0.0']])
end

RSpec.describe(NodeSemver, '#test_comparison') do
  def self.run_test(v0, v1, loose)
    it "v0=#{v0.inspect}, v1=#{v1.inspect}, loose=#{loose}" do
      expect(NodeSemver.gt(v0, v1, loose)).to(eq(true))
      expect(NodeSemver.lt(v1, v0, loose)).to(eq(true))
      expect(NodeSemver.gt(v1, v0, loose)).to(eq(false))
      expect(NodeSemver.lt(v0, v1, loose)).to(eq(false))
      expect(NodeSemver.eq(v0, v0, loose)).to(eq(true))
      expect(NodeSemver.eq(v1, v1, loose)).to(eq(true))
      expect(NodeSemver.cmp(v1, '==', v1, loose)).to(eq(true))
      expect(NodeSemver.cmp(v0, '>=', v1, loose)).to(eq(true))
      expect(NodeSemver.cmp(v1, '<=', v0, loose)).to(eq(true))
      expect(NodeSemver.cmp(v0, '!=', v1, loose)).to(eq(true))
    end
  end
  run_test('0.0.0', '0.0.0-foo', false)
  run_test('0.0.1', '0.0.0', false)
  run_test('1.0.0', '0.9.9', false)
  run_test('0.10.0', '0.9.0', false)
  run_test('0.99.0', '0.10.0', false)
  run_test('2.0.0', '1.2.3', false)
  run_test('v0.0.0', '0.0.0-foo', true)
  run_test('v0.0.1', '0.0.0', true)
  run_test('v1.0.0', '0.9.9', true)
  run_test('v0.10.0', '0.9.0', true)
  run_test('v0.99.0', '0.10.0', true)
  run_test('v2.0.0', '1.2.3', true)
  run_test('0.0.0', 'v0.0.0-foo', false)
  run_test('0.0.1', 'v0.0.0', false)
  run_test('1.0.0', 'v0.9.9', false)
  run_test('0.10.0', 'v0.9.0', false)
  run_test('0.99.0', 'v0.10.0', false)
  run_test('2.0.0', 'v1.2.3', false)
  run_test('1.2.3', '1.2.3-asdf', false)
  run_test('1.2.3', '1.2.3-4', false)
  run_test('1.2.3', '1.2.3-4-foo', false)
  run_test('1.2.3-5-foo', '1.2.3-5', false)
  run_test('1.2.3-5', '1.2.3-4', false)
  run_test('1.2.3-5-foo', '1.2.3-5-Foo', false)
  run_test('3.0.0', '2.7.2+asdf', false)
  run_test('1.2.3-a.10', '1.2.3-a.5', false)
  run_test('1.2.3-a.b', '1.2.3-a.5', false)
  run_test('1.2.3-a.b', '1.2.3-a', false)
  run_test('1.2.3-a.b.c.10.d.5', '1.2.3-a.b.c.5.d.100', false)
  run_test('1.2.3-r2', '1.2.3-r100', false)
  run_test('1.2.3-r100', '1.2.3-R2', false)
end

RSpec.describe(NodeSemver, '#test_equality') do
  def self.run_test(v0, v1, loose)
    it "v0=#{v0.inspect}, v1=#{v1.inspect}, loose=#{loose}" do
      expect(NodeSemver.eq(v0, v1, loose)).to(eq(true))
      expect(NodeSemver.neq(v0, v1, loose)).to(eq(false))
      expect(NodeSemver.cmp(v0, '==', v1, loose)).to(eq(true))
      expect(NodeSemver.cmp(v0, '!=', v1, loose)).to(eq(false))
      expect(NodeSemver.cmp(v0, '===', v1, loose)).to(eq(false))
      expect(NodeSemver.cmp(v0, '!==', v1, loose)).to(eq(true))
      expect(NodeSemver.gt(v0, v1, loose)).to(eq(false))
      expect(NodeSemver.gte(v0, v1, loose)).to(eq(true))
      expect(NodeSemver.lt(v0, v1, loose)).to(eq(false))
      expect(NodeSemver.lte(v0, v1, loose)).to(eq(true))
    end
  end
  run_test('1.2.3', 'v1.2.3', true)
  run_test('1.2.3', '=1.2.3', true)
  run_test('1.2.3', 'v 1.2.3', true)
  run_test('1.2.3', '= 1.2.3', true)
  run_test('1.2.3', ' v1.2.3', true)
  run_test('1.2.3', ' =1.2.3', true)
  run_test('1.2.3', ' v 1.2.3', true)
  run_test('1.2.3', ' = 1.2.3', true)
  run_test('1.2.3-0', 'v1.2.3-0', true)
  run_test('1.2.3-0', '=1.2.3-0', true)
  run_test('1.2.3-0', 'v 1.2.3-0', true)
  run_test('1.2.3-0', '= 1.2.3-0', true)
  run_test('1.2.3-0', ' v1.2.3-0', true)
  run_test('1.2.3-0', ' =1.2.3-0', true)
  run_test('1.2.3-0', ' v 1.2.3-0', true)
  run_test('1.2.3-0', ' = 1.2.3-0', true)
  run_test('1.2.3-1', 'v1.2.3-1', true)
  run_test('1.2.3-1', '=1.2.3-1', true)
  run_test('1.2.3-1', 'v 1.2.3-1', true)
  run_test('1.2.3-1', '= 1.2.3-1', true)
  run_test('1.2.3-1', ' v1.2.3-1', true)
  run_test('1.2.3-1', ' =1.2.3-1', true)
  run_test('1.2.3-1', ' v 1.2.3-1', true)
  run_test('1.2.3-1', ' = 1.2.3-1', true)
  run_test('1.2.3-beta', 'v1.2.3-beta', true)
  run_test('1.2.3-beta', '=1.2.3-beta', true)
  run_test('1.2.3-beta', 'v 1.2.3-beta', true)
  run_test('1.2.3-beta', '= 1.2.3-beta', true)
  run_test('1.2.3-beta', ' v1.2.3-beta', true)
  run_test('1.2.3-beta', ' =1.2.3-beta', true)
  run_test('1.2.3-beta', ' v 1.2.3-beta', true)
  run_test('1.2.3-beta', ' = 1.2.3-beta', true)
  run_test('1.2.3-beta+build', ' = 1.2.3-beta+otherbuild', true)
  run_test('1.2.3+build', ' = 1.2.3+otherbuild', true)
  run_test('1.2.3-beta+build', '1.2.3-beta+otherbuild', false)
  run_test('1.2.3+build', '1.2.3+otherbuild', false)
  run_test('  v1.2.3+build', '1.2.3+otherbuild', false)
end

RSpec.describe(NodeSemver, '#test_for_4digit') do
  def self.run_test(version, major, minor, patch, prerelease, build, micro_versions)
    it "version=#{version.inspect}" do
      semver = NodeSemver.make_semver(version, true)
      expect(semver.raw).to(eq(version))
      expect(semver.major).to(eq(major))
      expect(semver.minor).to(eq(minor))
      expect(semver.patch).to(eq(patch))
      expect(semver.prerelease).to(eq(prerelease))
      expect(semver.build).to(eq(build))
      expect(semver.micro_versions).to(eq(micro_versions))
    end
  end
  run_test('4.1.3', 4, 1, 3, [], [], [])
  run_test('4.1.3+jenkins', 4, 1, 3, [], ['jenkins'], [])
  run_test('4.1.3-pre', 4, 1, 3, ['pre'], [], [])
  run_test('4.1.3.2', 4, 1, 3, [], [], [2])
  run_test('4.1.3.2+jenkins', 4, 1, 3, [], ['jenkins'], [2])
  run_test('4.1.3.2-pre', 4, 1, 3, ['pre'], [], [2])
  run_test('4.1.3.2-pre2', 4, 1, 3, ['pre2'], [], [2])
  run_test('4.1.3.2-pre.2', 4, 1, 3, ['pre'], [], [2, 2])
  run_test('4.1.3.2-pre.2+xxx', 4, 1, 3, ['pre'], ['xxx'], [2, 2])
end

RSpec.describe(NodeSemver, '#test_increment_version') do
  def self.run_test(version, release, loose, identifier, expected)
    it "version=#{version.inspect}, release=#{release.inspect}, loose=#{loose}, identifier=#{identifier.inspect}" do
      expect(NodeSemver.inc(version, release, loose, identifier)).to(eq(expected))
    end
  end
  run_test('1.2.3', 'major', false, nil, '2.0.0')
  run_test('1.2.3', 'minor', false, nil, '1.3.0')
  run_test('1.2.3', 'patch', false, nil, '1.2.4')
  run_test('1.2.3tag', 'major', true, nil, '2.0.0')
  run_test('1.2.3-tag', 'major', false, nil, '2.0.0')
  run_test('1.2.3', 'fake', false, nil, nil)
  run_test('1.2.0-0', 'patch', false, nil, '1.2.0')
  run_test('fake', 'major', false, nil, nil)
  run_test('1.2.3-4', 'major', false, nil, '2.0.0')
  run_test('1.2.3-4', 'minor', false, nil, '1.3.0')
  run_test('1.2.3-4', 'patch', false, nil, '1.2.3')
  run_test('1.2.3-alpha.0.beta', 'major', false, nil, '2.0.0')
  run_test('1.2.3-alpha.0.beta', 'minor', false, nil, '1.3.0')
  run_test('1.2.3-alpha.0.beta', 'patch', false, nil, '1.2.3')
  run_test('1.2.4', 'prerelease', false, nil, '1.2.5-0')
  run_test('1.2.3-0', 'prerelease', false, nil, '1.2.3-1')
  run_test('1.2.3-alpha.0', 'prerelease', false, nil, '1.2.3-alpha.1')
  run_test('1.2.3-alpha.1', 'prerelease', false, nil, '1.2.3-alpha.2')
  run_test('1.2.3-alpha.2', 'prerelease', false, nil, '1.2.3-alpha.3')
  run_test('1.2.3-alpha.0.beta', 'prerelease', false, nil, '1.2.3-alpha.1.beta')
  run_test('1.2.3-alpha.1.beta', 'prerelease', false, nil, '1.2.3-alpha.2.beta')
  run_test('1.2.3-alpha.2.beta', 'prerelease', false, nil, '1.2.3-alpha.3.beta')
  run_test('1.2.3-alpha.10.0.beta', 'prerelease', false, nil, '1.2.3-alpha.10.1.beta')
  run_test('1.2.3-alpha.10.1.beta', 'prerelease', false, nil, '1.2.3-alpha.10.2.beta')
  run_test('1.2.3-alpha.10.2.beta', 'prerelease', false, nil, '1.2.3-alpha.10.3.beta')
  run_test('1.2.3-alpha.10.beta.0', 'prerelease', false, nil, '1.2.3-alpha.10.beta.1')
  run_test('1.2.3-alpha.10.beta.1', 'prerelease', false, nil, '1.2.3-alpha.10.beta.2')
  run_test('1.2.3-alpha.10.beta.2', 'prerelease', false, nil, '1.2.3-alpha.10.beta.3')
  run_test('1.2.3-alpha.9.beta', 'prerelease', false, nil, '1.2.3-alpha.10.beta')
  run_test('1.2.3-alpha.10.beta', 'prerelease', false, nil, '1.2.3-alpha.11.beta')
  run_test('1.2.3-alpha.11.beta', 'prerelease', false, nil, '1.2.3-alpha.12.beta')
  run_test('1.2.0', 'prepatch', false, nil, '1.2.1-0')
  run_test('1.2.0-1', 'prepatch', false, nil, '1.2.1-0')
  run_test('1.2.0', 'preminor', false, nil, '1.3.0-0')
  run_test('1.2.3-1', 'preminor', false, nil, '1.3.0-0')
  run_test('1.2.0', 'premajor', false, nil, '2.0.0-0')
  run_test('1.2.3-1', 'premajor', false, nil, '2.0.0-0')
  run_test('1.2.0-1', 'minor', false, nil, '1.2.0')
  run_test('1.0.0-1', 'major', false, nil, '1.0.0')
  run_test('1.2.3', 'major', false, 'dev', '2.0.0')
  run_test('1.2.3', 'minor', false, 'dev', '1.3.0')
  run_test('1.2.3', 'patch', false, 'dev', '1.2.4')
  run_test('1.2.3tag', 'major', true, 'dev', '2.0.0')
  run_test('1.2.3-tag', 'major', false, 'dev', '2.0.0')
  run_test('1.2.3', 'fake', false, 'dev', nil)
  run_test('1.2.0-0', 'patch', false, 'dev', '1.2.0')
  run_test('fake', 'major', false, 'dev', nil)
  run_test('1.2.3-4', 'major', false, 'dev', '2.0.0')
  run_test('1.2.3-4', 'minor', false, 'dev', '1.3.0')
  run_test('1.2.3-4', 'patch', false, 'dev', '1.2.3')
  run_test('1.2.3-alpha.0.beta', 'major', false, 'dev', '2.0.0')
  run_test('1.2.3-alpha.0.beta', 'minor', false, 'dev', '1.3.0')
  run_test('1.2.3-alpha.0.beta', 'patch', false, 'dev', '1.2.3')
  run_test('1.2.4', 'prerelease', false, 'dev', '1.2.5-dev.0')
  run_test('1.2.3-0', 'prerelease', false, 'dev', '1.2.3-dev.0')
  run_test('1.2.3-alpha.0', 'prerelease', false, 'dev', '1.2.3-dev.0')
  run_test('1.2.3-alpha.0', 'prerelease', false, 'alpha', '1.2.3-alpha.1')
  run_test('1.2.3-alpha.0.beta', 'prerelease', false, 'dev', '1.2.3-dev.0')
  run_test('1.2.3-alpha.0.beta', 'prerelease', false, 'alpha', '1.2.3-alpha.1.beta')
  run_test('1.2.3-alpha.10.0.beta', 'prerelease', false, 'dev', '1.2.3-dev.0')
  run_test('1.2.3-alpha.10.0.beta', 'prerelease', false, 'alpha', '1.2.3-alpha.10.1.beta')
  run_test('1.2.3-alpha.10.1.beta', 'prerelease', false, 'alpha', '1.2.3-alpha.10.2.beta')
  run_test('1.2.3-alpha.10.2.beta', 'prerelease', false, 'alpha', '1.2.3-alpha.10.3.beta')
  run_test('1.2.3-alpha.10.beta.0', 'prerelease', false, 'dev', '1.2.3-dev.0')
  run_test('1.2.3-alpha.10.beta.0', 'prerelease', false, 'alpha', '1.2.3-alpha.10.beta.1')
  run_test('1.2.3-alpha.10.beta.1', 'prerelease', false, 'alpha', '1.2.3-alpha.10.beta.2')
  run_test('1.2.3-alpha.10.beta.2', 'prerelease', false, 'alpha', '1.2.3-alpha.10.beta.3')
  run_test('1.2.3-alpha.9.beta', 'prerelease', false, 'dev', '1.2.3-dev.0')
  run_test('1.2.3-alpha.9.beta', 'prerelease', false, 'alpha', '1.2.3-alpha.10.beta')
  run_test('1.2.3-alpha.10.beta', 'prerelease', false, 'alpha', '1.2.3-alpha.11.beta')
  run_test('1.2.3-alpha.11.beta', 'prerelease', false, 'alpha', '1.2.3-alpha.12.beta')
  run_test('1.2.0', 'prepatch', false, 'dev', '1.2.1-dev.0')
  run_test('1.2.0-1', 'prepatch', false, 'dev', '1.2.1-dev.0')
  run_test('1.2.0', 'preminor', false, 'dev', '1.3.0-dev.0')
  run_test('1.2.3-1', 'preminor', false, 'dev', '1.3.0-dev.0')
  run_test('1.2.0', 'premajor', false, 'dev', '2.0.0-dev.0')
  run_test('1.2.3-1', 'premajor', false, 'dev', '2.0.0-dev.0')
  run_test('1.2.0-1', 'minor', false, 'dev', '1.2.0')
  run_test('1.0.0-1', 'major', false, 'dev', '1.0.0')
  run_test('1.2.3-dev.bar', 'prerelease', false, 'dev', '1.2.3-dev.0')
end

RSpec.describe(NodeSemver, '#test_invalid_version_number') do
  def self.run_test(version, loose, exception)
    it "version=#{version.inspect}, loose=#{loose} exception=#{exception.inspect}" do
      if exception.nil?
        expect{NodeSemver.make_semver(version, loose)}.to_not(raise_error)
      else
        expect{NodeSemver.make_semver(version, loose)}.to(raise_error(exception))
      end
    end
  end
  run_test('1.2.3.4', false, ArgumentError)
  run_test('NOT VALID', false, ArgumentError)
  run_test(1.2, false, ArgumentError)
  run_test("1.2", false, ArgumentError)
  run_test("1.a.2", false, ArgumentError)
  run_test(nil, false, ArgumentError)
  run_test('X.2', false, ArgumentError)
  run_test('Infinity.NaN.Infinity', false, ArgumentError)
  run_test('1.2.3.4', true, nil)
  run_test('NOT VALID', true, ArgumentError)
  run_test(1.2, true, ArgumentError)
  run_test("1.2", true, nil)
  run_test("1.a.2", true, ArgumentError)
  run_test(nil, true, ArgumentError)
  run_test('Infinity.NaN.Infinity', true, ArgumentError)
  run_test('X.2', true, ArgumentError)
end

RSpec.describe(NodeSemver, '#test_negative_range') do
  def self.run_test(range, version, loose)
    it "version=#{version.inspect}, range=#{range.inspect}, loose=#{loose}" do
      expect(NodeSemver.satisfies(version, range, loose)).to(eq(false))
    end
  end
  run_test('1.0.0 - 2.0.0', '2.2.3', false)
  run_test('1.2.3+asdf - 2.4.3+asdf', '1.2.3-pre.2', false)
  run_test('1.2.3+asdf - 2.4.3+asdf', '2.4.3-alpha', false)
  run_test('^1.2.3+build', '2.0.0', false)
  run_test('^1.2.3+build', '1.2.0', false)
  run_test('^1.2.3', '1.2.3-pre', false)
  run_test('^1.2', '1.2.0-pre', false)
  run_test('>1.2', '1.3.0-beta', false)
  run_test('<=1.2.3', '1.2.3-beta', false)
  run_test('^1.2.3', '1.2.3-beta', false)
  run_test('=0.7.x', '0.7.0-asdf', false)
  run_test('>=0.7.x', '0.7.0-asdf', false)
  run_test('1', '1.0.0beta', true)
  run_test('<1', '1.0.0beta', true)
  run_test('< 1', '1.0.0beta', true)
  run_test('1.0.0', '1.0.1', false)
  run_test('>=1.0.0', '0.0.0', false)
  run_test('>=1.0.0', '0.0.1', false)
  run_test('>=1.0.0', '0.1.0', false)
  run_test('>1.0.0', '0.0.1', false)
  run_test('>1.0.0', '0.1.0', false)
  run_test('<=2.0.0', '3.0.0', false)
  run_test('<=2.0.0', '2.9999.9999', false)
  run_test('<=2.0.0', '2.2.9', false)
  run_test('<2.0.0', '2.9999.9999', false)
  run_test('<2.0.0', '2.2.9', false)
  run_test('>=0.1.97', 'v0.1.93', true)
  run_test('>=0.1.97', '0.1.93', false)
  run_test('0.1.20 || 1.2.4', '1.2.3', false)
  run_test('>=0.2.3 || <0.0.1', '0.0.3', false)
  run_test('>=0.2.3 || <0.0.1', '0.2.2', false)
  run_test('2.x.x', '1.1.3', false)
  run_test('2.x.x', '3.1.3', false)
  run_test('1.2.x', '1.3.3', false)
  run_test('1.2.x || 2.x', '3.1.3', false)
  run_test('1.2.x || 2.x', '1.1.3', false)
  run_test('2.*.*', '1.1.3', false)
  run_test('2.*.*', '3.1.3', false)
  run_test('1.2.*', '1.3.3', false)
  run_test('1.2.* || 2.*', '3.1.3', false)
  run_test('1.2.* || 2.*', '1.1.3', false)
  run_test('2', '1.1.2', false)
  run_test('2.3', '2.4.1', false)
  run_test('~2.4', '2.5.0', false)  # >=2.4.0 <2.5.0
  run_test('~2.4', '2.3.9', false)
  run_test('~>3.2.1', '3.3.2', false)  # >=3.2.1 <3.3.0
  run_test('~>3.2.1', '3.2.0', false)  # >=3.2.1 <3.3.0
  run_test('~1', '0.2.3', false)  # >=1.0.0 <2.0.0
  run_test('~>1', '2.2.3', false)
  run_test('~1.0', '1.1.0', false)  # >=1.0.0 <1.1.0
  run_test('<1', '1.0.0', false)
  run_test('>=1.2', '1.1.1', false)
  run_test('1', '2.0.0beta', true)
  run_test('~v0.5.4-beta', '0.5.4-alpha', false)
  run_test('=0.7.x', '0.8.2', false)
  run_test('>=0.7.x', '0.6.2', false)
  run_test('<0.7.x', '0.7.2', false)
  run_test('<1.2.3', '1.2.3-beta', false)
  run_test('=1.2.3', '1.2.3-beta', false)
  run_test('>1.2', '1.2.8', false)
  run_test('^0.0.1', '0.0.2', false)
  run_test('^1.2.3', '2.0.0-alpha', false)
  run_test('^1.2.3', '1.2.2', false)
  run_test('^1.2', '1.1.9', false)
  run_test('*', 'v1.2.3-foo', true)
  # invalid ranges never satisfied!
  run_test('blerg', '1.2.3', false)
  run_test('git+https: #user:password0123@github.com/foo', '123.0.0', true)
  run_test('^1.2.3', '2.0.0-pre', false)
  run_test('^1.2.3', false, false)
end

RSpec.describe(NodeSemver, '#test_loose_range') do
  def self.run_test(loose_range, comparators)
    it "loose=#{loose_range.inspect} comparators=#{comparators.inspect}" do
      expect{NodeSemver.make_range(loose_range, false)}.to(raise_error(ArgumentError))
      expect(NodeSemver.make_range(loose_range, true).range).to(eq(comparators))
    end
  end
  run_test('>=01.02.03', '>=1.2.3')
  run_test('~1.02.03beta', '>=1.2.3-beta <1.3.0')
end

RSpec.describe(NodeSemver, '#test_loose_version') do
  def self.run_test(loose_version, strict_version)
    it "loose=#{loose_version.inspect} strict=#{strict_version.inspect}" do
      expect{NodeSemver.make_semver(loose_version, false)}.to(raise_error(ArgumentError))
      expect(NodeSemver.make_semver(loose_version, true).version).to(eq(strict_version))
      expect{NodeSemver.eq(loose_version, strict_version, false)}.to(raise_error(ArgumentError))
      expect(NodeSemver.eq(loose_version, strict_version, true)).to(eq(true))
      expect{NodeSemver.make_semver(strict_version, false).compare(loose_version)}.to(raise_error(ArgumentError))
    end
  end
  run_test('=1.2.3', '1.2.3')
  run_test('01.02.03', '1.2.3')
  run_test('1.2.3-beta.01', '1.2.3-beta.1')
  run_test('   =1.2.3', '1.2.3')
  run_test('1.2.3foo', '1.2.3-foo')
end

RSpec.describe(NodeSemver, '#test_ltr') do
  def self.run_test(range, version, loose)
    it "range=#{range.inspect} version=#{version.inspect} loose=#{loose}" do
      expect(NodeSemver.ltr(version, range, loose)).to(eq(true))
    end
  end
  run_test('0.1.20 || 1.2.4', '0.1.5', false)
  run_test('1', '0.0.0beta', true)
  run_test('1', '1.0.0beta', true)
  run_test('1.0.0 - 2.0.0', '0.0.1', false)
  run_test('1.0.0 - 2.0.0', '0.2.3', false)
  run_test('1.0.0', '0.0.0', false)
  run_test('1.0.0', '0.0.1', false)
  run_test('1.0.0-beta.2', '1.0.0-beta.1', false)
  run_test('1.2.* || 2.*', '1.1.3', false)
  run_test('1.2.* || 2.*', '1.1.9999', false)
  run_test('1.2.*', '1.1.3', false)
  run_test('1.2.x || 2.x', '1.0.0', false)
  run_test('1.2.x || 2.x', '1.1.3', false)
  run_test('1.2.x', '1.1.0', false)
  run_test('1.2.x', '1.1.3', false)
  run_test('2', '1.0.0', false)
  run_test('2', '1.0.0beta', true)
  run_test('2', '1.9999.9999', false)
  run_test('2.*.*', '1.0.1', false)
  run_test('2.*.*', '1.1.3', false)
  run_test('2.3', '2.2.1', false)
  run_test('2.3', '2.2.2', false)
  run_test('2.x.x', '1.0.0', false)
  run_test('2.x.x', '1.1.3', false)
  run_test('=0.7.x', '0.6.0', false)
  run_test('=0.7.x', '0.6.0-asdf', false)
  run_test('=0.7.x', '0.6.2', false)
  run_test('=0.7.x', '0.7.0-asdf', false)
  run_test('> 1', '1.0.0beta', true)
  run_test('> 1.2', '1.2.1', false)
  run_test('>1', '1.0.0', false)
  run_test('>1', '1.0.0beta', true)
  run_test('>1.2', '1.2.0', false)
  run_test('>1.2.3', '1.3.0-alpha', false)
  run_test('>2.0.0', '1.2.9', false)
  run_test('>2.0.0', '2.0.0', false)
  run_test('>=0.7.x', '0.6.0', false)
  run_test('>=0.7.x', '0.6.2', false)
  run_test('>=0.7.x', '0.7.0-asdf', false)
  run_test('>=2.0.0', '1.0.0', false)
  run_test('>=2.0.0', '1.1.1', false)
  run_test('>=2.0.0', '1.2.9', false)
  run_test('>=2.0.0', '1.9999.9999', false)
  run_test('^1', '1.0.0-0', false)
  run_test('~ 1.0', '0.1.0', false)
  run_test('~0.6.1-1', '0.6.1-0', false)
  run_test('~1', '0.2.3', false)
  run_test('~1.0', '0.0.0', false)
  run_test('~1.0', '0.1.2', false)
  run_test('~1.2.2', '1.2.1', false)
  run_test('~2.4', '2.3.0', false)
  run_test('~2.4', '2.3.5', false)
  run_test('~> 1', '0.2.3', false)
  run_test('~>1', '0.2.3', false)
  run_test('~>1', '0.2.4', false)
  run_test('~>3.2.1', '2.3.2', false)
  run_test('~>3.2.1', '3.2.0', false)
  run_test('~v0.5.4-pre', '0.5.4-alpha', false)
end

RSpec.describe(NodeSemver, '#test_max_satisfying')do
  def self.run_test(versions, range, expected, loose, include_prerelease)
    it "versions=#{versions}, range=#{range.inspect}, loose=#{loose}, include_prerelease=#{include_prerelease}" do
      if expected.class == Class and expected <= Exception
        expect{NodeSemver.max_satisfying(versions, range, loose, include_prerelease)}.to(raise_error(expected))
      else
        expect(NodeSemver.max_satisfying(versions, range, loose, include_prerelease)).to(eq(expected))
      end
    end
  end
  run_test(['1.2.4', '1.2.3', '1.2.5-beta'], '~1.2.3', '1.2.5-beta', false, true)
  run_test(['1.2.4', '1.2.3', '1.2.5-beta'], '~1.2.3', '1.2.4', false, false)
  run_test(['1.2.3', '1.2.4'], '1.2', '1.2.4', false, false)
  run_test(['1.2.4', '1.2.3'], '1.2', '1.2.4', false, false)
  run_test(['1.2.3', '1.2.4', '1.2.5', '1.2.6'], '~1.2.3', '1.2.6', false, false)
  run_test(['1.1.0', '1.2.0', '1.2.1', '1.3.0', '2.0.0b1', '2.0.0b2', '2.0.0b3', '2.0.0', '2.1.0'], '~2.0.0', '2.0.0', true, false)
  run_test(['1.1.0', '1.2.0', '1.2.1', '1.3.0', '2.0.0b1', '2.0.0b2', '2.0.0b3', '2.0.0', '2.1.0'], '~2.0.0', ArgumentError, false, false)
  run_test(['1.1.0', '1.2.0', '1.2.1', '1.3.0', '2.0.0b1', '2.0.0b2', '2.0.0', '2.0.1b1', '2.1.0'], '~2.0.0', '2.0.0', true, false)
  run_test(['1.1.0', '1.2.0', '1.2.1', '1.3.0', '2.0.0b1', '2.0.0b2', '2.0.0', '2.0.1b1', '2.1.0'], '~2.0.0', '2.0.1b1', true, true)
  run_test(["1.1.1", "1.2.0-pre", "1.2.0", "1.1.1-111", "1.1.1-21"], "<=1.2", "1.2.0", true, false)
  run_test(["1.1.1", "1.2.0-pre", "1.2", "1.1.1-111", "1.1.1-21"], "<=1.2", "1.2", true, false)
  run_test(["1.1.1", "1.2.0-pre", "1.2.0", "1.1.1-111", "1.1.1-21"], "<=1.2.0", "1.2.0", true, false)
  run_test(["1.1.1", "1.2.0-pre", "1.2", "1.1.1-111", "1.1.1-21"], "<=1.2.0", "1.2", true, false)
end

RSpec.describe(NodeSemver, '#test_min_satisfying') do
  def self.run_test(versions, range, expected, loose, include_prerelease)
    it "versions=#{versions}, range=#{range.inspect}, loose=#{loose}, include_prerelease=#{include_prerelease}" do
      if expected.class == Class and expected <= Exception
        expect{NodeSemver.min_satisfying(versions, range, loose, include_prerelease)}.to(raise_error(expected))
      else
        expect(NodeSemver.min_satisfying(versions, range, loose, include_prerelease)).to(eq(expected))
      end
    end
  end
  run_test(['1.2.3', '1.2.4'], '1.2', '1.2.3', false, false)
  run_test(['1.2.4', '1.2.3'], '1.2', '1.2.3', false, false)
  run_test(['1.2.3', '1.2.4', '1.2.5', '1.2.6'], '~1.2.3', '1.2.3', false, false)
  run_test(['1.1.0', '1.2.0', '1.2.1', '1.3.0', '2.0.0b1', '2.0.0b2', '2.0.0b3', '2.0.0', '2.1.0'], '~2.0.0', '2.0.0', true, false)
end

RSpec.describe(NodeSemver, '#test_sort') do
  def self.run_test(sorted_versions)
    it "versions.length=#{sorted_versions.length}" do
      unsorted_versions = sorted_versions
      until unsorted_versions != sorted_versions do
        unsorted_versions = sorted_versions.dup.shuffle
      end
      expect(NodeSemver.sort(unsorted_versions, true)).to(eq(sorted_versions))
      expect(NodeSemver.rsort(unsorted_versions, true)).to(eq(sorted_versions.reverse))
    end
  end
  run_test([
    '0.0.0-foo',
    '0.0.0',
    '0.0.0',
    '0.0.1', 
    '0.9.0',
    '0.9.9',
    '0.10.0',
    '0.10.0',
    '0.10.0',
    '0.99.0',
    '0.99.0',
    '1.0.0',
    '1.0.0',
    '1.2.3-4',
    '1.2.3-4',
    '1.2.3-5',
    '1.2.3-5',
    '1.2.3-4-foo',
    '1.2.3-5-Foo',
    '1.2.3-5-foo',
    '1.2.3-5-foo',
    '1.2.3-R2',
    '1.2.3-a',
    '1.2.3-a.5',
    '1.2.3-a.5',
    '1.2.3-a.10',
    '1.2.3-a.b',
    '1.2.3-a.b',
    '1.2.3-a.b.c.5.d.100',
    '1.2.3-a.b.c.10.d.5',
    '1.2.3-asdf',
    '1.2.3-r100',
    '1.2.3-r100',
    '1.2.3-r2',
    '1.2.3',
    '1.2.3',
    '2.0.0',
    '2.0.0',
    '2.7.2+asdf',
    '3.0.0',
  ])
  run_test([
    '1.0.0-alpha',
    '1.0.0-alpha.1',
    '1.0.0-alpha.beta',
    '1.0.0-beta',
    '1.0.0-beta.2',
    '1.0.0-beta.11',
    '1.0.0-rc.1',
    '1.0.0',
  ])
end

RSpec.describe(NodeSemver, '#test_range') do
  def self.run_test(range, version, loose, include_prerelease)
    it "version=#{version.inspect}, range=#{range.inspect}, loose=#{loose}, include_prerelease=#{include_prerelease}" do
      expect(NodeSemver.satisfies(version, range, loose, include_prerelease)).to(eq(true))
    end
  end
  run_test('1.0.0 - 2.0.0', '1.2.3', false, false)
  run_test('^1.2.3+build', '1.2.3', false, false)
  run_test('^1.2.3+build', '1.3.0', false, false)
  run_test('1.2.3-pre+asdf - 2.4.3-pre+asdf', '1.2.3', false, false)
  run_test('1.2.3pre+asdf - 2.4.3-pre+asdf', '1.2.3', true, false)
  run_test('1.2.3-pre+asdf - 2.4.3pre+asdf', '1.2.3', true, false)
  run_test('1.2.3pre+asdf - 2.4.3pre+asdf', '1.2.3', true, false)
  run_test('1.2.3-pre+asdf - 2.4.3-pre+asdf', '1.2.3-pre.2', false, false)
  run_test('1.2.3-pre+asdf - 2.4.3-pre+asdf', '2.4.3-alpha', false, false)
  run_test('1.2.3+asdf - 2.4.3+asdf', '1.2.3', false, false)
  run_test('1.0.0', '1.0.0', false, false)
  run_test('>=*', '0.2.4', false, false)
  run_test('', '1.0.0', false, false)
  run_test('*', '1.2.3', false, false)
  run_test('*', 'v1.2.3', true, false)
  run_test('>=1.0.0', '1.0.0', false, false)
  run_test('>=1.0.0', '1.0.1', false, false)
  run_test('>=1.0.0', '1.1.0', false, false)
  run_test('>1.0.0', '1.0.1', false, false)
  run_test('>1.0.0', '1.0.1-pre.1', false, true)
  run_test('>1.0.0', '1.1.0', false, false)
  run_test('<=2.0.0', '2.0.0', false, false)
  run_test('<=2.0.0', '1.9999.9999', false, false)
  run_test('<=2.0.0', '0.2.9', false, false)
  run_test('<2.0.0', '1.9999.9999', false, false)
  run_test('<2.0.0', '0.2.9', false, false)
  run_test('>= 1.0.0', '1.0.0', false, false)
  run_test('>=  1.0.0', '1.0.1', false, false)
  run_test('>=   1.0.0', '1.1.0', false, false)
  run_test('> 1.0.0', '1.0.1', false, false)
  run_test('>  1.0.0', '1.1.0', false, false)
  run_test('<=   2.0.0', '2.0.0', false, false)
  run_test('<= 2.0.0', '1.9999.9999', false, false)
  run_test('<=  2.0.0', '0.2.9', false, false)
  run_test('<    2.0.0', '1.9999.9999', false, false)
  run_test("<\t2.0.0", '0.2.9', false, false)
  run_test('>=0.1.97', 'v0.1.97', true, false)
  run_test('>=0.1.97', '0.1.97', false, false)
  run_test('0.1.20 || 1.2.4', '1.2.4', false, false)
  run_test('>=0.2.3 || <0.0.1', '0.0.0', false, false)
  run_test('>=0.2.3 || <0.0.1', '0.2.3', false, false)
  run_test('>=0.2.3 || <0.0.1', '0.2.4', false, false)
  run_test('||', '1.3.4', false, false)
  run_test('2.x.x', '2.1.3', false, false)
  run_test('1.2.x', '1.2.3', false, false)
  run_test('1.2.x || 2.x', '2.1.3', false, false)
  run_test('1.2.x || 2.x', '1.2.3', false, false)
  run_test('x', '1.2.3', false, false)
  run_test('2.*.*', '2.1.3', false, false)
  run_test('1.2.*', '1.2.3', false, false)
  run_test('1.2.* || 2.*', '2.1.3', false, false)
  run_test('1.2.* || 2.*', '1.2.3', false, false)
  run_test('*', '1.2.3', false, false)
  run_test('2', '2.1.2', false, false)
  run_test('2.3', '2.3.1', false, false)
  run_test('~x', '0.0.9', false, false)
  run_test('~2', '2.0.9', false, false)
  run_test('~2.4', '2.4.0', false, false)
  run_test('~2.4', '2.4.5', false, false)
  run_test('~>3.2.1', '3.2.2', false, false)
  run_test('~1', '1.2.3', false, false)
  run_test('~>1', '1.2.3', false, false)
  run_test('~> 1', '1.2.3', false, false)
  run_test('~1.0', '1.0.2', false, false)
  run_test('~ 1.0', '1.0.2', false, false)
  run_test('~ 1.0.3', '1.0.12', false, false)
  run_test('>=1', '1.0.0', false, false)
  run_test('>= 1', '1.0.0', false, false)
  run_test('<1.2', '1.1.1', false, false)
  run_test('< 1.2', '1.1.1', false, false)
  run_test('~v0.5.4-pre', '0.5.5', false, false)
  run_test('~v0.5.4-pre', '0.5.4', false, false)
  run_test('=0.7.x', '0.7.2', false, false)
  run_test('<=0.7.x', '0.7.2', false, false)
  run_test('>=0.7.x', '0.7.2', false, false)
  run_test('<=0.7.x', '0.6.2', false, false)
  run_test('~1.2.1 >=1.2.3', '1.2.3', false, false)
  run_test('~1.2.1 =1.2.3', '1.2.3', false, false)
  run_test('~1.2.1 1.2.3', '1.2.3', false, false)
  run_test('~1.2.1 >=1.2.3 1.2.3', '1.2.3', false, false)
  run_test('~1.2.1 1.2.3 >=1.2.3', '1.2.3', false, false)
  run_test('~1.2.1 1.2.3', '1.2.3', false, false)
  run_test('>=1.2.1 1.2.3', '1.2.3', false, false)
  run_test('1.2.3 >=1.2.1', '1.2.3', false, false)
  run_test('>=1.2.3 >=1.2.1', '1.2.3', false, false)
  run_test('>=1.2.1 >=1.2.3', '1.2.3', false, false)
  run_test('>=1.2', '1.2.8', false, false)
  run_test('^1.2.3', '1.8.1', false, false)
  run_test('^0.1.2', '0.1.2', false, false)
  run_test('^0.1', '0.1.2', false, false)
  run_test('^0.0.1', '0.0.1', false, false)
  run_test('^1.2', '1.4.2', false, false)
  run_test('^1.2 ^1', '1.4.2', false, false)
  run_test('^1.2.3-alpha', '1.2.3-pre', false, false)
  run_test('^1.2.3-alpha', '1.2.4-pre', false, true)
  run_test('^1.2.0-alpha', '1.2.0-pre', false, false)
  run_test('^0.0.1-alpha', '0.0.1-beta', false, false)
  run_test('^0.1.1-alpha', '0.1.1-beta', false, false)
  run_test('^x', '1.2.3', false, false)
  run_test('x - 1.0.0', '0.9.7', false, false)
  run_test('x - 1.x', '0.9.7', false, false)
  run_test('1.0.0 - x', '1.9.7', false, false)
  run_test('1.x - x', '1.9.7', false, false)
  run_test('<=7.x', '7.9.9', false, false)
end

RSpec.describe(NodeSemver, '#test_valid_range') do
  def self.run_test(range, loose, expected)
    it "range=#{range.inspect}, loose=#{loose}" do
      expect(NodeSemver.valid_range(range, loose)).to(eq(expected))
    end
  end
  run_test('1.0.0 - 2.0.0', false, '>=1.0.0 <=2.0.0')
  run_test('1.0.0', false, '1.0.0')
  run_test('>=*', false, '*')
  run_test('', false, '*')
  run_test('*', false, '*')
  run_test('*', false, '*')
  run_test('>=1.0.0', false, '>=1.0.0')
  run_test('>1.0.0', false, '>1.0.0')
  run_test('<=2.0.0', false, '<=2.0.0')
  run_test('1', false, '>=1.0.0 <2.0.0')
  run_test('<=2.0.0', false, '<=2.0.0')
  run_test('<=2.0.0', false, '<=2.0.0')
  run_test('<2.0.0', false, '<2.0.0')
  run_test('<2.0.0', false, '<2.0.0')
  run_test('>= 1.0.0', false, '>=1.0.0')
  run_test('>=  1.0.0', false, '>=1.0.0')
  run_test('>=   1.0.0', false, '>=1.0.0')
  run_test('> 1.0.0', false, '>1.0.0')
  run_test('>  1.0.0', false, '>1.0.0')
  run_test('<=   2.0.0', false, '<=2.0.0')
  run_test('<= 2.0.0', false, '<=2.0.0')
  run_test('<=  2.0.0', false, '<=2.0.0')
  run_test('<    2.0.0', false, '<2.0.0')
  run_test('<	2.0.0', false, '<2.0.0')
  run_test('>=0.1.97', false, '>=0.1.97')
  run_test('>=0.1.97', false, '>=0.1.97')
  run_test('0.1.20 || 1.2.4', false, '0.1.20||1.2.4')
  run_test('>=0.2.3 || <0.0.1', false, '>=0.2.3||<0.0.1')
  run_test('>=0.2.3 || <0.0.1', false, '>=0.2.3||<0.0.1')
  run_test('>=0.2.3 || <0.0.1', false, '>=0.2.3||<0.0.1')
  run_test('||', false, '||')
  run_test('2.x.x', false, '>=2.0.0 <3.0.0')
  run_test('1.2.x', false, '>=1.2.0 <1.3.0')
  run_test('1.2.x || 2.x', false, '>=1.2.0 <1.3.0||>=2.0.0 <3.0.0')
  run_test('1.2.x || 2.x', false, '>=1.2.0 <1.3.0||>=2.0.0 <3.0.0')
  run_test('x', false, '*')
  run_test('2.*.*', false, '>=2.0.0 <3.0.0')
  run_test('1.2.*', false, '>=1.2.0 <1.3.0')
  run_test('1.2.* || 2.*', false, '>=1.2.0 <1.3.0||>=2.0.0 <3.0.0')
  run_test('*', false, '*')
  run_test('2', false, '>=2.0.0 <3.0.0')
  run_test('2.3', false, '>=2.3.0 <2.4.0')
  run_test('~2.4', false, '>=2.4.0 <2.5.0')
  run_test('~2.4', false, '>=2.4.0 <2.5.0')
  run_test('~>3.2.1', false, '>=3.2.1 <3.3.0')
  run_test('~1', false, '>=1.0.0 <2.0.0')
  run_test('~>1', false, '>=1.0.0 <2.0.0')
  run_test('~> 1', false, '>=1.0.0 <2.0.0')
  run_test('~1.0', false, '>=1.0.0 <1.1.0')
  run_test('~ 1.0', false, '>=1.0.0 <1.1.0')
  run_test('^0', false, '>=0.0.0 <1.0.0')
  run_test('^ 1', false, '>=1.0.0 <2.0.0')
  run_test('^0.1', false, '>=0.1.0 <0.2.0')
  run_test('^1.0', false, '>=1.0.0 <2.0.0')
  run_test('^1.2', false, '>=1.2.0 <2.0.0')
  run_test('^0.0.1', false, '>=0.0.1 <0.0.2')
  run_test('^0.0.1-beta', false, '>=0.0.1-beta <0.0.2')
  run_test('^0.1.2', false, '>=0.1.2 <0.2.0')
  run_test('^1.2.3', false, '>=1.2.3 <2.0.0')
  run_test('^1.2.3-beta.4', false, '>=1.2.3-beta.4 <2.0.0')
  run_test('<1', false, '<1.0.0')
  run_test('< 1', false, '<1.0.0')
  run_test('>=1', false, '>=1.0.0')
  run_test('>= 1', false, '>=1.0.0')
  run_test('<1.2', false, '<1.2.0')
  run_test('< 1.2', false, '<1.2.0')
  run_test('1', false, '>=1.0.0 <2.0.0')
  run_test('>01.02.03', true, '>1.2.3')
  run_test('>01.02.03', false, nil)
  run_test('~1.2.3beta', true, '>=1.2.3-beta <1.3.0')
  run_test('~1.2.3beta', false, nil)
  run_test('^ 1.2 ^ 1', false, '>=1.2.0 <2.0.0 >=1.0.0 <2.0.0')
end
