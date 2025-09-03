#
# This source file is part of the EdgeDB open source project.
#
# Copyright 2018-present MagicStack Inc. and the EdgeDB authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

CREATE MODULE ext::jaldis;


## Functions
## ---------

CREATE FUNCTION
ext::jaldis::generate_typed_id(content_type: std::int64) -> std::uuid
{
    CREATE ANNOTATION std::description := 'Return a typed content UUID.';
    SET volatility := 'Volatile';
    USING EDGEQL $$
        with
          microseconds := math::floor(((<int64>datetime_get(datetime_of_statement(), 'epochseconds') * 1000) + <int64>str_split(str_split(<str>datetime_of_statement(), '.')[1], '+')[0] / 1000)),
          content_type := to_bytes(<int16>bit_lshift(content_type, 2), Endian.Big),
          rand := to_bytes(uuid_generate_v4()),
          uuid_bytes := to_bytes(<int64>microseconds, Endian.Big)[2:] ++ rand[6:10] ++ content_type ++ rand[12:16],
          uuid_hex := str_replace(<str>to_uuid(uuid_bytes), '-', '')
        select <uuid>(uuid_hex[0:12] ++ "8" ++ uuid_hex[13:32])
    $$;
};
