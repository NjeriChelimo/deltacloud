# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

class CIMI::Model::MachineImage < CIMI::Model::Base

  acts_as_root_entity

  text :state
  text :type
  text :image_location
  href :related_image

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    images = []
    if id == :all
      images = context.driver.images(context.credentials)
      images.map { |image| from_image(image, context) }
    else
      image = context.driver.image(context.credentials, :id => id)
      from_image(image, context)
    end
  end

  def self.from_image(image, context)
    self.new(
      :id => context.machine_image_url(image.id),
      :name => image.id,
      :description => image.description,
      :state => image.state || 'UNKNOWN',
      :type => "IMAGE",
      :created => image.creation_time.nil? ?
        Time.now.xmlschema : Time.parse(image.creation_time.to_s).xmlschema
    )
  end

  def self.delete!(image_id, context)
    context.driver.destroy_image(context.credentials, image_id)
    new(:id => image_id).destroy
  end

end
