// <copyright file="NotifyPropertyChangedInvocatorAttribute.cs" company="JetBrains s.r.o.">
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

    /// <summary>Indicates that the method is contained in a type that implements
    /// <see cref="System.ComponentModel.INotifyPropertyChanged" /> interface
    /// and this method is used to notify that some property value changed.</summary>
    /// <example>
    ///   <code>
    /// public class Foo : INotifyPropertyChanged
    /// {
    /// public event PropertyChangedEventHandler PropertyChanged;
    /// [NotifyPropertyChangedInvocator]
    /// protected virtual void NotifyChanged(string propertyName)
    /// {}
    /// private string _name;
    /// public string Name
    /// {
    /// get { return _name; }
    /// set
    /// {
    /// _name = value;
    /// NotifyChanged("LastName"); // Warning
    /// }
    /// }
    /// }
    ///   </code>
    /// Examples of generated notifications:
    ///   <list>
    ///   <item><c>NotifyChanged("Property")</c></item>
    ///   <item><c>NotifyChanged(() =&gt; Property)</c></item>
    ///   <item><c>NotifyChanged((VM x) =&gt; x.Property)</c></item>
    ///   <item><c>SetProperty(ref myField, value, "Property")</c></item>
    ///   </list>
    /// </example>
    /// <remarks>The method should be non-static and conform to one of the supported signatures:
    ///   <list>
    ///   <item><c>NotifyChanged(string)</c></item>
    ///   <item><c>NotifyChanged(params string[])</c></item>
    ///   <item><c>NotifyChanged{T}(Expression{Func{T}})</c></item>
    ///   <item><c>NotifyChanged{T,U}(Expression{Func{T,U}})</c></item>
    ///   <item><c>SetProperty{T}(ref T, T, string)</c></item>
    ///   </list>
    /// </remarks>
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = true)]
    public sealed class NotifyPropertyChangedInvocatorAttribute : Attribute
    {
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code")]
        public NotifyPropertyChangedInvocatorAttribute()
        {
        }

        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code")]
        public NotifyPropertyChangedInvocatorAttribute(string parameterName)
        {
            this.ParameterName = parameterName;
        }

        [UsedImplicitly]
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code")]
        public string ParameterName { get; private set; }
    }
}