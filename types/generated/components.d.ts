import type { Schema, Struct } from '@strapi/strapi';

export interface SharedSeoComponents extends Struct.ComponentSchema {
  collectionName: 'components_shared_seo_components';
  info: {
    displayName: 'Seo Components';
  };
  attributes: {
    keywords: Schema.Attribute.String;
    metaDescription: Schema.Attribute.Text & Schema.Attribute.Required;
    metaImage: Schema.Attribute.Media<
      'images' | 'files' | 'videos' | 'audios'
    > &
      Schema.Attribute.Required;
    metaTile: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

declare module '@strapi/strapi' {
  export namespace Public {
    export interface ComponentSchemas {
      'shared.seo-components': SharedSeoComponents;
    }
  }
}
