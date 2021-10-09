require 'bundler/setup'
require 'unity-dynamodb-attribute-deserializer'

describe Unity::DynamoDB::AttributeDeserializer do
  it "should decode DynamoDB attributes to Ruby values" do
    attributes = {
      'partition_key' => { 'S' => 'test' },
      'sort_key' => { 'N' => '123456.5444587778511245' },
      'my_map' => {
        'M' => {
          'test-key-str' => { 'S' => 'test-value' },
          'test-key-number' => { 'N' => '12345678.8771' },
          'test-key-map' => {
            'M' => {
              'test-subkey-str' => { 'S' => 'test-subvalue' }
            }
          }
        }
      },
      'my_array' => { 'L' => [{ 'S' => 'str1' }, { 'N' => '1234.567' }] }
    }

    item = Unity::DynamoDB::AttributeDeserializer.call(attributes)
    expect(item['partition_key']).to eql('test')
    expect(item['sort_key']).to eql(BigDecimal('123456.5444587778511245'))
    expect(item['my_map']).to(
      eql(
        {
          'test-key-str' => 'test-value',
          'test-key-number' => BigDecimal('12345678.8771'),
          'test-key-map' => {
            'test-subkey-str' => 'test-subvalue'
          }
        }
      )
    )
    expect(item['my_array']).to(eql(['str1', BigDecimal('1234.567')]))
  end
end
