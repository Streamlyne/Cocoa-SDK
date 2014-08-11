//
//  SLSerializer.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLObject.h"
#import "SLTransformProtocol.h"

@interface SLSerializer : SLObject

/**
 
 */
//-(void)registerTransform:(Class<SLTransformProtocol> *)transform forClass:(Class)cls DEPRECATED_ATTRIBUTE;

/**
 
 ```
 Class<SLTransformProtocol> transform = [self transformForAttributeType:type];
 if (transform != nil)
 {
 val = [transform deserialize:origVal];
 ```
 
 }
 */
-(Class<SLTransformProtocol>)transformForAttributeType:(NSAttributeType)type;

/**
 Called when the server has returned a payload representing multiple records, such as in response to a findAll or findQuery.
 
 It is your opportunity to clean up the server's response into the normalized form expected by Ember Data.
 
 If you want, you can just restructure the top-level of your payload, and do more fine-grained normalization in the normalize method.
 */
- (NSArray *) extractArray:(Class)modelClass withPayload:(NSDictionary *)payload withStore:(SLStore *)store;

/**
 
 */
- (NSDictionary *)extractSingle:(Class)modelClass withPayload:(NSDictionary *)payload withStore:(SLStore *)store;

/**
 Normalizes a part of the JSON payload returned by
 the server. You should override this method, munge the hash
 and call super if you have generic normalization to do.
 
 It takes the type of the record that is being normalized
 (as a DS.Model class), the property where the hash was
 originally found, and the hash to normalize.
 
 For example, if you have a payload that looks like this:
 
 ```js
 {
 "post": {
 "id": 1,
 "title": "Rails is omakase",
 "comments": [ 1, 2 ]
 },
 "comments": [{
 "id": 1,
 "body": "FIRST"
 }, {
 "id": 2,
 "body": "Rails is unagi"
 }]
 }
 ```
 
 The `normalize` method will be called three times:
 
 * With `App.Post`, `"posts"` and `{ id: 1, title: "Rails is omakase", ... }`
 * With `App.Comment`, `"comments"` and `{ id: 1, body: "FIRST" }`
 * With `App.Comment`, `"comments"` and `{ id: 2, body: "Rails is unagi" }`
 
 You can use this method, for example, to normalize underscored keys to camelized
 or other general-purpose normalizations.
 
 If you want to do normalizations specific to some part of the payload, you
 can specify those under `normalizeHash`.
 
 For example, if the `IDs` under `"comments"` are provided as `_id` instead of
 `id`, you can specify how to normalize just the comments:
 
 ```js
 App.PostSerializer = DS.RESTSerializer.extend({
 normalizeHash: {
 comments: function(hash) {
 hash.id = hash._id;
 delete hash._id;
 return hash;
 }
 }
 });
 ```
 
 The key under `normalizeHash` is just the original key that was in the original
 payload.
 
 @method normalize
 @param {subclass of DS.Model} type
 @param {Object} hash
 @param {String} prop
 @return {Object}
 */
- (NSDictionary *)normalize:(Class)modelClass withPayload:(NSDictionary *)payload;

/**
 
 @private
 */
- (NSDictionary *)normalizeAttributes:(Class)modelClass withPayload:(NSDictionary *)payload;

/**
 @private
 */
- (NSDictionary *)normalizeRelationships:(Class)modelClass withPayload:(NSDictionary *)payload;

/**
 You can use this method to normalize all payloads, regardless of whether they
 represent single records or an array.
 
 For example, you might want to remove some extraneous data from the payload:
 
 ```js
 App.ApplicationSerializer = DS.RESTSerializer.extend({
 normalizePayload: function(payload) {
 delete payload.version;
 delete payload.status;
 return payload;
 }
 });
 ```
 
 @method normalizePayload
 @param {Object} payload
 @return {Object} the normalized payload
 */
- (NSDictionary *)normalizeIdWithPayload:(NSDictionary *)payload;


/**
 keyForAttribute can be used to define rules for how to convert an attribute name in your model to a key in your JSON.
 */
- (NSString *)keyForAttribute:(NSString *)attribute;


/**
 keyForRelationship can be used to define a custom key when serializing relationship properties. By default JSONSerializer does not provide an implementation of this method.
 */
- (NSString *)keyForRelationship:(NSString *)relationship;


/**
 Create a JSON representation of the record, using the serialization strategy of the store's adapter.
 
 serialize takes an optional hash as a parameter, currently supported options are:
 
 includeId: true if the record's ID should be included in the JSON representation.
 */
- (NSDictionary *) serialize:(SLModel *)record withOptions:(NSDictionary *)options;

/**
 `serializeAttribute` can be used to customize how `DS.attr`
 properties are serialized
 
 For example if you wanted to ensure all your attributes were always
 serialized as properties on an `attributes` object you could
 write:
 
 ```javascript
 App.ApplicationSerializer = DS.JSONSerializer.extend({
 serializeAttribute: function(record, json, key, attributes) {
 json.attributes = json.attributes || {};
 this._super(record, json.attributes, key, attributes);
 }
 });
 ```
 
 @method serializeAttribute
 @param {DS.Model} record
 @param {Object} json
 @param {String} key
 @param {Object} attribute
 */
- (NSDictionary *) serializeAttribute:(SLModel *)record withKey:(NSString *)key withData:(NSDictionary *)data;

/**
 `serializeBelongsTo` can be used to customize how `DS.belongsTo`
 properties are serialized.
 
 Example
 
 ```javascript
 App.PostSerializer = DS.JSONSerializer.extend({
 serializeBelongsTo: function(record, json, relationship) {
 var key = relationship.key;
 
 var belongsTo = get(record, key);
 
 key = this.keyForRelationship ? this.keyForRelationship(key, "belongsTo") : key;
 
 json[key] = Ember.isNone(belongsTo) ? belongsTo : belongsTo.toJSON();
 }
 });
 ```
 
 @method serializeBelongsTo
 @param {DS.Model} record
 @param {Object} json
 @param {Object} relationship
 */

- (NSDictionary *) serializeBelongsTo:(SLModel *)record withKey:(NSString *)key withData:(NSDictionary *)data;

/**
 `serializeHasMany` can be used to customize how `DS.hasMany`
 properties are serialized.
 
 Example
 
 ```javascript
 App.PostSerializer = DS.JSONSerializer.extend({
 serializeHasMany: function(record, json, relationship) {
 var key = relationship.key;
 if (key === 'comments') {
 return;
 } else {
 this._super.apply(this, arguments);
 }
 }
 });
 ```
 
 @method serializeHasMany
 @param {DS.Model} record
 @param {Object} json
 @param {Object} relationship
 */

- (NSDictionary *) serializeHasMany:(SLModel *)record withKey:(NSString *)key withData:(NSDictionary *)data;

@end
