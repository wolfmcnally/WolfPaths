Pod::Spec.new do |s|
    s.name             = 'WolfPaths'
    s.version          = '0.1.0'
    s.summary          = 'Pure Swift bezier path manipulation, using Double as the primitive floating-point type instead of CGFloat. Based heavily on BezierKit by Holmes Futrell.'

    # s.description      = <<-DESC
    # TODO: Add long description of the pod here.
    # DESC

    s.homepage         = 'https://github.com/wolfmcnally/WolfPaths'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Wolf McNally' => 'wolf@wolfmcnally.com' }
    s.source           = { :git => 'https://github.com/wolfmcnally/WolfPaths.git', :tag => s.version.to_s }

    s.swift_version = '4.2'

    s.source_files = 'WolfPaths/Classes/**/*'

    s.ios.deployment_target = '9.3'
    s.macos.deployment_target = '10.13'
    s.tvos.deployment_target = '11.0'

    s.module_name = 'WolfPaths'
    s.dependency 'BezierKit'
    s.dependency 'VectorBoolean'
    s.dependency 'WolfGeometry'
end
