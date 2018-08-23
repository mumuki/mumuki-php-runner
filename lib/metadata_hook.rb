class PhpMetadataHook < Mumukit::Hook
  def metadata
    {
      language: {
        name: 'php',
        icon: {type: 'devicon', name: 'php'},
        version: 'v1.0.0',
        extension: 'php',
        ace_mode: 'php'
      },
      test_framework: {
        name: 'phpunit',
        version: '7',
        test_extension: 'php',
        template: <<php
public function testDescriptionExample(): void {
  $this->assertTrue(true);
}
php
      }
    }
  end
end
