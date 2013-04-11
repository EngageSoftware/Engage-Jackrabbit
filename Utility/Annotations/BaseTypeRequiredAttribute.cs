// <copyright file="BaseTypeRequiredAttribute.cs" company="JetBrains s.r.o.">
// Copyright 2007-2012 JetBrains s.r.o.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>

namespace JetBrains.Annotations
{
    using System;
    using System.Diagnostics.CodeAnalysis;

    /// <summary>When applied to a target attribute, specifies a requirement for any type marked with
    /// the target attribute to implement or inherit specific type or types.</summary>
    /// <example>
    ///   <code>
    /// [BaseTypeRequired(typeof(IComponent)] // Specify requirement
    /// public class ComponentAttribute : Attribute
    /// {}
    /// [Component] // ComponentAttribute requires implementing IComponent interface
    /// public class MyComponent : IComponent
    /// {}
    ///   </code>
    /// </example>
    [SuppressMessage("Microsoft.Design", "CA1019:DefineAccessorsForAttributeArguments", Justification = "Jetbrains code")]
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true, Inherited = true)]
    [BaseTypeRequired(typeof(Attribute))]
    public sealed class BaseTypeRequiredAttribute : Attribute
    {
        /// <summary>Initializes a new instance of the <see cref="BaseTypeRequiredAttribute"/> class</summary>
        /// <param name="baseType">Specifies which types are required</param>
        public BaseTypeRequiredAttribute(Type baseType)
        {
            this.BaseTypes = new[] { baseType };
        }

        /// <summary>Gets enumerations of specified base types</summary>
        [SuppressMessage("Microsoft.Performance", "CA1819:PropertiesShouldNotReturnArrays", Justification = "Jetbrains code")]
        public Type[] BaseTypes { get; private set; }
    }
}